<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Expenses\IndexExpenseRequest;
use App\Http\Requests\Expenses\StoreExpenseRequest;
use App\Models\User;
use App\Services\ExpenseService;
use Illuminate\Http\JsonResponse;

class ExpensesController extends Controller
{
    public function __construct(
        private readonly ExpenseService $expenseService,
    ) {}

    public function index(IndexExpenseRequest $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        $validated = $request->validated();

        $result = $this->expenseService->listExpenses(
            $user,
            $user->role === 'Business Owner' ? (int) $validated['sector_id'] : null,
            (int) ($validated['per_page'] ?? 15),
        );

        return response()->json([
            'data' => $result['data'],
            'meta' => $result['meta'],
            'message' => 'Expenses retrieved successfully.',
        ]);
    }

    public function store(StoreExpenseRequest $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        $validated = $request->validated();

        $sectorId = $user->role === 'Business Owner'
            ? (int) $validated['sector_id']
            : $user->sector_id;

        return response()->json([
            'data' => $this->expenseService->recordExpense($user, $sectorId, $validated),
            'message' => 'Expense recorded successfully.',
        ], 201);
    }
}
