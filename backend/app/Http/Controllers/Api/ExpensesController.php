<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Expenses\IndexExpenseRequest;
use App\Http\Requests\Expenses\StoreExpenseRequest;
use App\Http\Requests\Expenses\UpdateExpenseRequest;
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
            'message' => 'Expenses retrieved successfully.',
        ]);
    }

    public function show(int $expense): JsonResponse
    {
        /** @var User $user */
        $user = request()->user();

        return response()->json([
            'data' => $this->expenseService->showExpense($user, $expense),
            'message' => 'Expense retrieved successfully.',
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

    public function update(UpdateExpenseRequest $request, int $expense): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        $validated = $request->validated();

        $sectorId = isset($validated['sector_id']) && $user->role === 'Business Owner'
            ? (int) $validated['sector_id']
            : null;

        return response()->json([
            'data' => $this->expenseService->updateExpense($user, $expense, $validated, $sectorId),
            'message' => 'Expense updated successfully.',
        ]);
    }

    public function destroy(int $expense): JsonResponse
    {
        /** @var User $user */
        $user = request()->user();

        $this->expenseService->deleteExpense($user, $expense);

        return response()->json([
            'message' => 'Expense deleted successfully.',
        ]);
    }
}
