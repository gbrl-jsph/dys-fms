<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Sales\IndexSaleRequest;
use App\Http\Requests\Sales\StoreSaleRequest;
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
        );

        return response()->json([
            'data' => $result['data'],
            'meta' => $result['meta'],
            'message' => 'Sales transactions retrieved successfully.',
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
}
