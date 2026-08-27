<?php

namespace App\Services;

use App\Models\Expense;
use App\Models\User;
use Illuminate\Support\Carbon;

class ExpenseService
{
    /**
     * Lists expense transactions ordered by recorded_at descending (most
     * recent first). The Business Owner filters by the provided sector_id;
     * the Event Manager is always scoped to the assigned sector (the
     * sector_id parameter is overridden, per TC-FR005-05).
     *
     * Supports search/filter: search (description), date_from/date_to,
     * amount_min/amount_max.
     *
     * @return array{data: \Illuminate\Support\Collection, meta: array{
     *     current_page: int, per_page: int, total: int, last_page: int
     * }}
     */
    public function listExpenses(User $user, ?int $sectorId, int $perPage = 15, array $filters = []): array
    {
        $query = Expense::with(['user', 'sector']);

        if ($user->role === 'Event Manager') {
            $query->where('sector_id', $user->sector_id);
        } else {
            $query->where('sector_id', $sectorId);
        }

        if (!empty($filters['search'])) {
            $query->where('description', 'like', '%'.$filters['search'].'%');
        }

        if (!empty($filters['date_from'])) {
            $query->whereDate('recorded_at', '>=', $filters['date_from']);
        }

        if (!empty($filters['date_to'])) {
            $query->whereDate('recorded_at', '<=', $filters['date_to']);
        }

        if (isset($filters['amount_min'])) {
            $query->where('amount', '>=', $filters['amount_min']);
        }

        if (isset($filters['amount_max'])) {
            $query->where('amount', '<=', $filters['amount_max']);
        }

        $paginator = $query->orderByDesc('recorded_at')->paginate($perPage);

        return [
            'data' => $paginator->getCollection()->map(
                fn (Expense $expense) => $this->format($expense)
            )->values(),
            'meta' => [
                'current_page' => $paginator->currentPage(),
                'per_page' => $paginator->perPage(),
                'total' => $paginator->total(),
                'last_page' => $paginator->lastPage(),
            ],
        ];
    }

    /**
     * Records an expense. user_id, sector_id and recorded_at are set
     * server-side (never client-supplied); payroll_record_id stays null for manual
     * entries (set only by the payroll system, TC-FR005-01).
     */
    public function recordExpense(User $user, int $sectorId, array $data): array
    {
        $expense = Expense::create([
            'user_id' => $user->id,
            'sector_id' => $sectorId,
            'amount' => $data['amount'],
            'description' => $data['description'] ?? null,
        ]);

        $expense->refresh()->load(['user', 'sector']);

        $this->logAudit($user, 'expense_created', $expense);

        return $this->format($expense);
    }

    public function showExpense(User $user, int $id): array
    {
        $expense = Expense::with(['user', 'sector'])->findOrFail($id);

        $this->authorizeAccess($user, $expense);

        return $this->format($expense);
    }

    public function updateExpense(User $user, int $id, array $data, ?int $sectorId = null): array
    {
        $expense = Expense::findOrFail($id);

        $this->authorizeAccess($user, $expense);

        if ($expense->payroll_record_id !== null) {
            abort(403, 'Payroll-generated expenses cannot be edited.');
        }

        $old = $expense->toArray();

        $updateData = [];

        if (isset($data['amount'])) {
            $updateData['amount'] = $data['amount'];
        }

        if (array_key_exists('description', $data)) {
            $updateData['description'] = $data['description'];
        }

        if (isset($data['recorded_at'])) {
            $updateData['recorded_at'] = $data['recorded_at'];
        }

        if ($sectorId !== null && $user->role === 'Business Owner') {
            $updateData['sector_id'] = $sectorId;
        }

        $expense->update($updateData);
        $expense->refresh()->load(['user', 'sector']);

        $this->logAudit($user, 'expense_updated', $expense, $old, $expense->toArray());

        return $this->format($expense);
    }

    public function deleteExpense(User $user, int $id): void
    {
        $expense = Expense::findOrFail($id);

        $this->authorizeAccess($user, $expense);

        if ($expense->payroll_record_id !== null) {
            abort(403, 'Payroll-generated expenses cannot be deleted.');
        }

        $old = $expense->toArray();

        $expense->delete();

        $this->logAudit($user, 'expense_deleted', $expense, $old, null);
    }

    private function authorizeAccess(User $user, Expense $expense): void
    {
        if ($user->role === 'Business Owner') {
            return;
        }

        if ($user->role === 'Event Manager' && $expense->sector_id === $user->sector_id) {
            return;
        }

        abort(403, 'Forbidden.');
    }

    private function logAudit(User $user, string $action, Expense $expense, ?array $old = null, ?array $new = null): void
    {
        try {
            \App\Models\AuditLog::create([
                'user_id' => $user->id,
                'action' => $action,
                'auditable_type' => Expense::class,
                'auditable_id' => $expense->id,
                'old_values' => $old,
                'new_values' => $new,
                'ip_address' => request()->ip(),
            ]);
        } catch (\Throwable $e) {
            \Illuminate\Support\Facades\Log::warning('Audit log failed: '.$e->getMessage());
        }
    }

    private function format(Expense $expense): array
    {
        return [
            'id' => $expense->id,
            'amount' => (float) $expense->amount,
            'description' => $expense->description,
            'recorded_by' => [
                'id' => $expense->user->id,
                'name' => $expense->user->name,
            ],
            'sector' => [
                'id' => $expense->sector->id,
                'name' => $expense->sector->name,
            ],
            'payroll_record_id' => $expense->payroll_record_id,
            'recorded_at' => Carbon::parse($expense->recorded_at)->toIso8601String(),
            'updated_at' => $expense->updated_at ? Carbon::parse($expense->updated_at)->toIso8601String() : null,
            'created_at' => $expense->recorded_at ? Carbon::parse($expense->recorded_at)->toIso8601String() : null,
        ];
    }
}
