<?php

namespace App\Services;

use App\Models\BusinessSector;
use App\Models\Expense;
use App\Models\SalesTransaction;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;

class ReportsService
{
    /**
     * Generates the report for the given role scope:
     * - Event Manager: always the assigned sector (sector_id overridden,
     *   TC-FR007-03); analytics is rejected in the middleware.
     * - Business Owner without sector_id: cross-sector aggregation.
     * - Business Owner with sector_id: single-sector report.
     *
     * Only approved data is returned: total sales, total expenses, net
     * balance, and the analytics chart placeholders (empty arrays are a
     * valid no-data state per api-specification).
     *
     * @return array{data: array, message: string}
     */
    public function generateReport(User $user, array $filters): array
    {
        $type = $filters['type'] ?? 'summary';
        $dateFrom = $filters['date_from'] ?? null;
        $dateTo = $filters['date_to'] ?? null;

        $sectorId = $user->role === 'Event Manager'
            ? $user->sector_id
            : ($filters['sector_id'] ?? null);

        if ($type === 'analytics') {
            $summary = $this->totals($sectorId, $dateFrom, $dateTo);
            unset($summary['payroll_expenses']);

            return [
                'data' => [
                    'charts' => [
                        'sales_trend' => [],
                        'expense_breakdown' => [],
                        'sector_comparison' => [],
                    ],
                    'summary' => $summary,
                ],
                'message' => 'Analytics report generated successfully.',
            ];
        }

        if ($user->role === 'Business Owner' && $sectorId === null) {
            return [
                'data' => $this->crossSectorReport($dateFrom, $dateTo),
                'message' => 'Cross-sector report generated successfully.',
            ];
        }

        return [
            'data' => $this->sectorReport($sectorId, $dateFrom, $dateTo),
            'message' => 'Report generated successfully.',
        ];
    }

    private function sectorReport(int $sectorId, ?string $dateFrom, ?string $dateTo): array
    {
        $sector = BusinessSector::findOrFail($sectorId);
        $totals = $this->totals($sectorId, $dateFrom, $dateTo);

        return [
            'sector' => [
                'id' => $sector->id,
                'name' => $sector->name,
            ],
            'summary' => $totals,
            'period' => $this->period($dateFrom, $dateTo),
        ];
    }

    private function crossSectorReport(?string $dateFrom, ?string $dateTo): array
    {
        $salesTotals = $this->salesQuery($dateFrom, $dateTo)
            ->selectRaw('sector_id, SUM(amount) as total')
            ->groupBy('sector_id')
            ->pluck('total', 'sector_id');

        $expenseTotals = $this->expenseQuery($dateFrom, $dateTo)
            ->selectRaw('sector_id, SUM(amount) as total')
            ->groupBy('sector_id')
            ->pluck('total', 'sector_id');

        $sectorIds = $salesTotals->keys()->merge($expenseTotals->keys())
            ->map(fn ($id) => (int) $id)
            ->unique()
            ->sort()
            ->values();

        $sectorNames = BusinessSector::whereIn('id', $sectorIds)->pluck('name', 'id');

        $sectors = $sectorIds->map(function (int $id) use ($salesTotals, $expenseTotals, $sectorNames) {
            $sales = (float) ($salesTotals[$id] ?? 0);
            $expenses = (float) ($expenseTotals[$id] ?? 0);

            return [
                'id' => $id,
                'name' => $sectorNames[$id],
                'total_sales' => $sales,
                'total_expenses' => $expenses,
                'net_balance' => round($sales - $expenses, 2),
            ];
        })->values();

        $totalSales = (float) $this->salesQuery($dateFrom, $dateTo)->sum('amount');
        $totalExpenses = (float) $this->expenseQuery($dateFrom, $dateTo)->sum('amount');

        return [
            'cross_sector' => true,
            'sectors' => $sectors->all(),
            'grand_total' => [
                'total_sales' => $totalSales,
                'total_expenses' => $totalExpenses,
                'net_balance' => round($totalSales - $totalExpenses, 2),
            ],
            'period' => $this->period($dateFrom, $dateTo),
        ];
    }

    private function totals(?int $sectorId, ?string $dateFrom, ?string $dateTo): array
    {
        $salesQuery = $this->salesQuery($dateFrom, $dateTo);
        $expenseQuery = $this->expenseQuery($dateFrom, $dateTo);

        if ($sectorId !== null) {
            $salesQuery->where('sector_id', $sectorId);
            $expenseQuery->where('sector_id', $sectorId);
        }

        $totalSales = (float) $salesQuery->sum('amount');
        $totalExpenses = (float) $expenseQuery->sum('amount');
        $payrollExpenses = (float) (clone $expenseQuery)
            ->whereNotNull('payroll_record_id')
            ->sum('amount');

        return [
            'total_sales' => $totalSales,
            'total_expenses' => $totalExpenses,
            'net_balance' => round($totalSales - $totalExpenses, 2),
            'payroll_expenses' => $payrollExpenses,
        ];
    }

    private function salesQuery(?string $dateFrom, ?string $dateTo): Builder
    {
        return $this->applyDateRange(SalesTransaction::query(), $dateFrom, $dateTo);
    }

    private function expenseQuery(?string $dateFrom, ?string $dateTo): Builder
    {
        return $this->applyDateRange(Expense::query(), $dateFrom, $dateTo);
    }

    private function applyDateRange(Builder $query, ?string $dateFrom, ?string $dateTo): Builder
    {
        if ($dateFrom !== null) {
            $query->whereDate('recorded_at', '>=', $dateFrom);
        }

        if ($dateTo !== null) {
            $query->whereDate('recorded_at', '<=', $dateTo);
        }

        return $query;
    }

    private function period(?string $dateFrom, ?string $dateTo): array
    {
        return [
            'date_from' => $dateFrom,
            'date_to' => $dateTo,
        ];
    }
}
