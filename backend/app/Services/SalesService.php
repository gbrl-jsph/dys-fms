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
     * @return array{data: \Illuminate\Support\Collection, meta: array{
     *     current_page: int, per_page: int, total: int, last_page: int
     * }}
     */
    public function listSales(User $user, ?int $sectorId, int $perPage = 15): array
    {
        $query = SalesTransaction::with(['user', 'sector']);

        if ($user->role === 'Event Manager') {
            $query->where('sector_id', $user->sector_id);
        } else {
            $query->where('sector_id', $sectorId);
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
     * client-supplied); sales records are immutable after creation (BR-17).
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

        return $this->format($transaction);
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
        ];
    }
}
