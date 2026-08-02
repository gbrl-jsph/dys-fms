<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Payroll\IndexPayrollRequest;
use App\Http\Requests\Payroll\StorePayrollRequest;
use App\Models\User;
use App\Services\PayrollService;
use Illuminate\Http\JsonResponse;

class PayrollController extends Controller
{
    public function __construct(
        private readonly PayrollService $payrollService,
    ) {}

    public function index(IndexPayrollRequest $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        $validated = $request->validated();

        $result = $this->payrollService->listPayroll(
            $user,
            $request->query('sector_id') !== null ? (int) $request->query('sector_id') : null,
            $request->query('user_id') !== null ? (int) $request->query('user_id') : null,
            (int) ($validated['per_page'] ?? 15),
        );

        return response()->json([
            'data' => $result['data'],
            'meta' => $result['meta'],
            'message' => 'Payroll records retrieved successfully.',
        ]);
    }

    public function store(StorePayrollRequest $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        return response()->json([
            'data' => $this->payrollService->calculatePayroll($user, $request->validated()),
            'message' => 'Payroll calculated and saved successfully. Expense record auto-created.',
        ], 201);
    }
}
