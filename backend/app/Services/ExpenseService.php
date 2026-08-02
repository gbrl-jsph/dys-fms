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
     * @return array{data: \Illuminate\Support\Collection, meta: array{
     *     current_page: int, per_page: int, total: int, last_page: int
     * }}
     */
    public function listExpenses(User $user, ?int $sectorId, int $perPage = 15): array
    {
        $query = Expense::with(['user', 'sector']);

        if ($user->role === 'Event Manager') {
            $query->where('sector_id', $user->sector_id);
        } else {
            $query->where('sector_id', $sectorId);
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
     * server-side (never client-supplied); expense records are immutable
     * after creation (BR-18). payroll_record_id stays null for manual
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

        return $this->format($expense);
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
        ];
    }
}
