<?php

namespace App\Services;

use App\Models\SalesTransaction;
use App\Models\User;
use Illuminate\Support\Carbon;

class SalesService
{
    /**
     * Lists sales transactions ordered by recorded_at descending (most
     * recent first). The Business Owner filters by the provided sector_id;
     * the Event Manager is always scoped to the assigned sector (the
     * sector_id parameter is overridden, per TC-FR004-05).
     *
     * Supports search/filter: search (description), date_from/date_to,
     * amount_min/amount_max.
     *
     * @return array{data: \Illuminate\Support\Collection, meta: array{
     *     current_page: int, per_page: int, total: int, last_page: int
     * }}
     */
    public function listSales(User $user, ?int $sectorId, int $perPage = 15, array $filters = []): array
    {
        $query = SalesTransaction::with(['user', 'sector']);

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
                fn (SalesTransaction $transaction) => $this->format($transaction)
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
     * Records a sale. user_id and recorded_at are set server-side (never
     * client-supplied).
     */
    public function recordSale(User $user, int $sectorId, array $data): array
    {
        $transaction = SalesTransaction::create([
            'user_id' => $user->id,
            'sector_id' => $sectorId,
            'amount' => $data['amount'],
            'description' => $data['description'] ?? null,
        ]);

        $transaction->refresh()->load(['user', 'sector']);

        $this->logAudit($user, 'sale_created', $transaction);

        return $this->format($transaction);
    }

    public function showSale(User $user, int $id): array
    {
        $transaction = SalesTransaction::with(['user', 'sector'])->findOrFail($id);

        $this->authorizeAccess($user, $transaction);

        return $this->format($transaction);
    }

    public function updateSale(User $user, int $id, array $data, ?int $sectorId = null): array
    {
        $transaction = SalesTransaction::findOrFail($id);

        $this->authorizeAccess($user, $transaction);

        $old = $transaction->toArray();

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

        $transaction->update($updateData);
        $transaction->refresh()->load(['user', 'sector']);

        $this->logAudit($user, 'sale_updated', $transaction, $old, $transaction->toArray());

        return $this->format($transaction);
    }

    public function deleteSale(User $user, int $id): void
    {
        $transaction = SalesTransaction::findOrFail($id);

        $this->authorizeAccess($user, $transaction);

        $old = $transaction->toArray();

        $transaction->delete();

        $this->logAudit($user, 'sale_deleted', $transaction, $old, null);
    }

    private function authorizeAccess(User $user, SalesTransaction $transaction): void
    {
        if ($user->role === 'Business Owner') {
            return;
        }

        if ($user->role === 'Event Manager' && $transaction->sector_id === $user->sector_id) {
            return;
        }

        abort(403, 'Forbidden.');
    }

    private function logAudit(User $user, string $action, SalesTransaction $transaction, ?array $old = null, ?array $new = null): void
    {
        try {
            \App\Models\AuditLog::create([
                'user_id' => $user->id,
                'action' => $action,
                'auditable_type' => SalesTransaction::class,
                'auditable_id' => $transaction->id,
                'old_values' => $old,
                'new_values' => $new,
                'ip_address' => request()->ip(),
            ]);
        } catch (\Throwable $e) {
            \Illuminate\Support\Facades\Log::warning('Audit log failed: '.$e->getMessage());
        }
    }

    private function format(SalesTransaction $transaction): array
    {
        return [
            'id' => $transaction->id,
            'amount' => (float) $transaction->amount,
            'description' => $transaction->description,
            'recorded_by' => [
                'id' => $transaction->user->id,
                'name' => $transaction->user->name,
            ],
            'sector' => [
                'id' => $transaction->sector->id,
                'name' => $transaction->sector->name,
            ],
            'recorded_at' => Carbon::parse($transaction->recorded_at)->toIso8601String(),
            'updated_at' => $transaction->updated_at ? Carbon::parse($transaction->updated_at)->toIso8601String() : null,
            'created_at' => $transaction->recorded_at ? Carbon::parse($transaction->recorded_at)->toIso8601String() : null,
        ];
    }
}
