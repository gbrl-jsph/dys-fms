<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Sales\IndexSaleRequest;
use App\Http\Requests\Sales\StoreSaleRequest;
use App\Http\Requests\Sales\UpdateSaleRequest;
use App\Models\User;
use App\Services\SalesService;
use Illuminate\Http\JsonResponse;

class SalesController extends Controller
{
    public function __construct(
        private readonly SalesService $salesService,
    ) {}

    public function index(IndexSaleRequest $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        $validated = $request->validated();

        $result = $this->salesService->listSales(
            $user,
            $user->role === 'Business Owner' ? (int) $validated['sector_id'] : null,
            (int) ($validated['per_page'] ?? 15),
            [
                'search' => $validated['search'] ?? null,
                'date_from' => $validated['date_from'] ?? null,
                'date_to' => $validated['date_to'] ?? null,
                'amount_min' => $validated['amount_min'] ?? null,
                'amount_max' => $validated['amount_max'] ?? null,
            ],
        );

        return response()->json([
            'data' => $result['data'],
            'meta' => $result['meta'],
            'message' => 'Sales transactions retrieved successfully.',
        ]);
    }

    public function show(int $sale): JsonResponse
    {
        /** @var User $user */
        $user = request()->user();

        return response()->json([
            'data' => $this->salesService->showSale($user, $sale),
            'message' => 'Sale retrieved successfully.',
        ]);
    }

    public function store(StoreSaleRequest $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        $validated = $request->validated();

        $sectorId = $user->role === 'Business Owner'
            ? (int) $validated['sector_id']
            : $user->sector_id;

        return response()->json([
            'data' => $this->salesService->recordSale($user, $sectorId, $validated),
            'message' => 'Sale recorded successfully.',
        ], 201);
    }

    public function update(UpdateSaleRequest $request, int $sale): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        $validated = $request->validated();

        $sectorId = isset($validated['sector_id']) && $user->role === 'Business Owner'
            ? (int) $validated['sector_id']
            : null;

        return response()->json([
            'data' => $this->salesService->updateSale($user, $sale, $validated, $sectorId),
            'message' => 'Sale updated successfully.',
        ]);
    }

    public function destroy(int $sale): JsonResponse
    {
        /** @var User $user */
        $user = request()->user();

        $this->salesService->deleteSale($user, $sale);

        return response()->json([
            'message' => 'Sale deleted successfully.',
        ]);
    }
}
