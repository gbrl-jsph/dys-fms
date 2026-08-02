<?php

namespace App\Services;

use App\Models\Expense;
use App\Models\PayrollRecord;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

class PayrollService
{
    /**
     * Lists payroll records ordered by calculated_at descending (most
     * recent first). The Business Owner sees all records with optional
     * sector_id / user_id filters; the Event Manager and Employee are
     * always scoped to their own records (the filters are ignored, per
     * TC-FR006-05/06/08).
     *
     * @return array{data: \Illuminate\Support\Collection, meta: array{
     *     current_page: int, per_page: int, total: int, last_page: int
     * }}
     */
    public function listPayroll(User $user, ?int $sectorId, ?int $userId, int $perPage = 15): array
    {
        $query = PayrollRecord::with(['user', 'sector', 'expense']);

        if ($user->role === 'Business Owner') {
            if ($sectorId !== null) {
                $query->where('sector_id', $sectorId);
            }
            if ($userId !== null) {
                $query->where('user_id', $userId);
            }
        } else {
            $query->where('user_id', $user->id);
        }

        $paginator = $query->orderByDesc('calculated_at')->paginate($perPage);

        return [
            'data' => $paginator->getCollection()->map(
                fn (PayrollRecord $record) => $this->format($record)
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
     * Calculates payroll (computed_salary = hours_worked × hourly_rate,
     * server-side, BR-22) and persists the record together with an
     * auto-created Expense in ONE database transaction (BR-20). If the
     * expense cannot be created the payroll record rolls back, and vice
     * versa. The Expense description follows the approved template
     * "Payroll — {employee_name} — {pay_period}"; its recorded_at is set
     * to the same timestamp as the payroll calculated_at (TC-FR006-06).
     *
     * @return array
     */
    public function calculatePayroll(User $user, array $data): array
    {
        $employee = User::findOrFail($data['user_id']);

        $computedSalary = round((float) $data['hours_worked'] * (float) $data['hourly_rate'], 2);
        $now = Carbon::now();

        $record = DB::transaction(function () use ($user, $employee, $data, $computedSalary, $now) {
            $payrollRecord = new PayrollRecord([
                'user_id' => $employee->id,
                'sector_id' => $employee->sector_id,
                'hours_worked' => $data['hours_worked'],
                'hourly_rate' => $data['hourly_rate'],
                'computed_salary' => $computedSalary,
                'pay_period' => $data['pay_period'],
            ]);
            $payrollRecord->calculated_at = $now;
            $payrollRecord->save();

            $expense = new Expense([
                'user_id' => $user->id,
                'sector_id' => $employee->sector_id,
                'amount' => $computedSalary,
                'description' => "Payroll — {$employee->name} — {$data['pay_period']}",
                'payroll_record_id' => $payrollRecord->id,
            ]);
            $expense->recorded_at = $now;
            $expense->save();

            return $payrollRecord;
        });

        $record->refresh()->load(['user', 'sector', 'expense']);

        return $this->format($record, true);
    }

    private function format(PayrollRecord $record, bool $includeExpenseDescription = false): array
    {
        $expense = $record->expense;

        return [
            'id' => $record->id,
            'employee' => [
                'id' => $record->user->id,
                'name' => $record->user->name,
            ],
            'sector' => [
                'id' => $record->sector->id,
                'name' => $record->sector->name,
            ],
            'hours_worked' => (float) $record->hours_worked,
            'hourly_rate' => (float) $record->hourly_rate,
            'computed_salary' => (float) $record->computed_salary,
            'pay_period' => Carbon::parse($record->pay_period)->format('Y-m-d'),
            'calculated_at' => Carbon::parse($record->calculated_at)->toIso8601String(),
            'expense' => $expense ? array_merge([
                'id' => $expense->id,
                'amount' => (float) $expense->amount,
            ], $includeExpenseDescription ? ['description' => $expense->description] : []) : null,
        ];
    }
}
