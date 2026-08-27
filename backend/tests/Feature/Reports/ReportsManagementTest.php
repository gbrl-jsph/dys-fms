<?php

namespace Tests\Feature\Reports;

use App\Models\BusinessSector;
use App\Models\Expense;
use App\Models\PayrollRecord;
use App\Models\SalesTransaction;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class ReportsManagementTest extends TestCase
{
    use RefreshDatabase;

    private BusinessSector $eventsSector;

    private BusinessSector $bandysSector;

    private User $owner;

    private User $maria;

    private User $ana;

    protected function setUp(): void
    {
        parent::setUp();

        $this->eventsSector = BusinessSector::create([
            'name' => 'DYS Events',
            'description' => 'Event coordination and styling main branch',
        ]);

        $this->bandysSector = BusinessSector::create([
            'name' => 'B&DYS',
            'description' => 'Styling and makeup branch',
        ]);

        $this->owner = User::create([
            'name' => 'Juan Dela Cruz',
            'email' => 'owner@dys.com',
            'password' => Hash::make('SecurePass123'),
            'role' => 'Business Owner',
            'sector_id' => null,
            'account_status' => 'Active',
        ]);

        $this->maria = User::create([
            'name' => 'Maria Santos',
            'email' => 'maria@dys.com',
            'password' => Hash::make('SecurePass123'),
            'role' => 'Event Manager',
            'sector_id' => $this->bandysSector->id,
            'account_status' => 'Active',
        ]);

        $this->ana = User::create([
            'name' => 'Ana Reyes',
            'email' => 'ana@dys.com',
            'password' => Hash::make('SecurePass123'),
            'role' => 'Employee/Staff',
            'sector_id' => $this->eventsSector->id,
            'account_status' => 'Active',
        ]);
    }

    private function authenticate(string $email): string
    {
        $response = $this->postJson('/api/login', [
            'email' => $email,
            'password' => 'SecurePass123',
        ]);

        return $response->json('data.token');
    }

    private function createSale(int $sectorId, float $amount, string $recordedAt, int $userId): SalesTransaction
    {
        $sale = new SalesTransaction([
            'user_id' => $userId,
            'sector_id' => $sectorId,
            'amount' => $amount,
            'description' => "Sale {$amount}",
        ]);
        $sale->recorded_at = $recordedAt;
        $sale->save();

        return $sale;
    }

    private function createExpense(int $sectorId, float $amount, string $recordedAt, int $userId, ?int $payrollRecordId = null): Expense
    {
        $expense = new Expense([
            'user_id' => $userId,
            'sector_id' => $sectorId,
            'amount' => $amount,
            'description' => $payrollRecordId === null ? "Expense {$amount}" : 'Payroll — Ana Reyes — 2026-07-15',
            'payroll_record_id' => $payrollRecordId,
        ]);
        $expense->recorded_at = $recordedAt;
        $expense->save();

        return $expense;
    }

    private function seedCrossSectorData(): void
    {
        $this->createSale($this->eventsSector->id, 150000.00, '2026-07-01 10:00:00', $this->owner->id);
        $this->createSale($this->bandysSector->id, 75000.00, '2026-07-02 10:00:00', $this->owner->id);
        $this->createExpense($this->eventsSector->id, 85000.00, '2026-07-03 10:00:00', $this->owner->id);
        $this->createExpense($this->bandysSector->id, 32000.00, '2026-07-04 10:00:00', $this->owner->id);
    }

    public function test_owner_gets_cross_sector_report_when_no_sector_filter(): void
    {
        $this->seedCrossSectorData();

        $response = $this->withHeader('Authorization', 'Bearer '.$this->authenticate('owner@dys.com'))
            ->getJson('/api/reports')
            ->assertStatus(200)
            ->assertJson([
                'data' => [
                    'cross_sector' => true,
                    'sectors' => [
                        [
                            'id' => $this->eventsSector->id,
                            'name' => 'DYS Events',
                            'total_sales' => 150000.0,
                            'total_expenses' => 85000.0,
                            'net_balance' => 65000.0,
                        ],
                        [
                            'id' => $this->bandysSector->id,
                            'name' => 'B&DYS',
                            'total_sales' => 75000.0,
                            'total_expenses' => 32000.0,
                            'net_balance' => 43000.0,
                        ],
                    ],
                    'grand_total' => [
                        'total_sales' => 225000.0,
                        'total_expenses' => 117000.0,
                        'net_balance' => 108000.0,
                    ],
                    'period' => [
                        'date_from' => null,
                        'date_to' => null,
                    ],
                ],
                'message' => 'Cross-sector report generated successfully.',
            ]);
    }

    public function test_owner_gets_single_sector_report_with_sector_filter(): void
    {
        $this->seedCrossSectorData();

        $payrollRecord = new PayrollRecord([
            'user_id' => $this->ana->id,
            'sector_id' => $this->eventsSector->id,
            'hours_worked' => 320.00,
            'hourly_rate' => 125.00,
            'computed_salary' => 40000.00,
            'pay_period' => '2026-07-15',
        ]);
        $payrollRecord->calculated_at = '2026-07-20 10:00:00';
        $payrollRecord->save();

        $this->createExpense($this->eventsSector->id, 40000.00, '2026-07-20 10:00:00', $this->owner->id, $payrollRecord->id);

        $response = $this->withHeader('Authorization', 'Bearer '.$this->authenticate('owner@dys.com'))
            ->getJson('/api/reports?sector_id='.$this->eventsSector->id)
            ->assertStatus(200)
            ->assertJson([
                'data' => [
                    'sector' => [
                        'id' => $this->eventsSector->id,
                        'name' => 'DYS Events',
                    ],
                    'summary' => [
                        'total_sales' => 150000.0,
                        'total_expenses' => 125000.0,
                        'net_balance' => 25000.0,
                        'payroll_expenses' => 40000.0,
                    ],
                ],
                'message' => 'Report generated successfully.',
            ]);
    }

    public function test_owner_report_types_sales_and_expenses_return_200(): void
    {
        $this->seedCrossSectorData();

        $token = $this->authenticate('owner@dys.com');

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/reports?sector_id='.$this->eventsSector->id.'&type=sales')
            ->assertStatus(200)
            ->assertJson([
                'data' => [
                    'sector' => ['id' => $this->eventsSector->id],
                    'summary' => ['total_sales' => 150000.0],
                ],
            ]);

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/reports?sector_id='.$this->bandysSector->id.'&type=expenses')
            ->assertStatus(200)
            ->assertJson([
                'data' => [
                    'sector' => ['id' => $this->bandysSector->id],
                    'summary' => ['total_expenses' => 32000.0],
                ],
            ]);

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/reports?type=sales')
            ->assertStatus(200)
            ->assertJson([
                'data' => [
                    'cross_sector' => true,
                    'grand_total' => ['total_sales' => 225000.0],
                ],
            ]);
    }

    public function test_owner_date_range_filter_is_applied(): void
    {
        $this->createSale($this->eventsSector->id, 1000.00, '2026-01-15 10:00:00', $this->owner->id);
        $this->createSale($this->eventsSector->id, 2000.00, '2026-05-15 10:00:00', $this->owner->id);
        $this->createSale($this->eventsSector->id, 3000.00, '2026-08-15 10:00:00', $this->owner->id);
        $this->createExpense($this->eventsSector->id, 500.00, '2026-03-01 10:00:00', $this->owner->id);
        $this->createExpense($this->eventsSector->id, 700.00, '2026-09-01 10:00:00', $this->owner->id);

        $this->withHeader('Authorization', 'Bearer '.$this->authenticate('owner@dys.com'))
            ->getJson('/api/reports?sector_id='.$this->eventsSector->id.'&date_from=2026-01-01&date_to=2026-07-28')
            ->assertStatus(200)
            ->assertJson([
                'data' => [
                    'summary' => [
                        'total_sales' => 3000.0,
                        'total_expenses' => 500.0,
                        'net_balance' => 2500.0,
                    ],
                    'period' => [
                        'date_from' => '2026-01-01',
                        'date_to' => '2026-07-28',
                    ],
                ],
            ]);
    }

    public function test_event_manager_reports_are_scoped_to_assigned_sector_ignoring_sector_id(): void
    {
        $this->seedCrossSectorData();

        $token = $this->authenticate('maria@dys.com');

        $assigned = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/reports')
            ->assertStatus(200)
            ->assertJson([
                'data' => [
                    'sector' => [
                        'id' => $this->bandysSector->id,
                        'name' => 'B&DYS',
                    ],
                    'summary' => [
                        'total_sales' => 75000.0,
                        'total_expenses' => 32000.0,
                        'net_balance' => 43000.0,
                    ],
                ],
                'message' => 'Report generated successfully.',
            ]);

        $this->assertArrayNotHasKey('cross_sector', $assigned->json('data'));
        $this->assertArrayNotHasKey('grand_total', $assigned->json('data'));

        $overridden = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/reports?sector_id='.$this->eventsSector->id)
            ->assertStatus(200)
            ->assertJson([
                'data' => [
                    'sector' => ['id' => $this->bandysSector->id],
                    'summary' => ['total_sales' => 75000.0],
                ],
            ]);

        $this->assertArrayNotHasKey('cross_sector', $overridden->json('data'));

        $invalidSector = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/reports?sector_id=999')
            ->assertStatus(200)
            ->assertJson([
                'data' => [
                    'sector' => ['id' => $this->bandysSector->id],
                ],
            ]);

        $this->assertArrayNotHasKey('cross_sector', $invalidSector->json('data'));
    }

    public function test_event_manager_analytics_type_is_forbidden(): void
    {
        $this->withHeader('Authorization', 'Bearer '.$this->authenticate('maria@dys.com'))
            ->getJson('/api/reports?type=analytics')
            ->assertStatus(403)
            ->assertJson([
                'message' => 'Forbidden. Analytics dashboard is available for Business Owner only.',
            ]);
    }

    public function test_owner_analytics_returns_charts_and_summary(): void
    {
        $this->seedCrossSectorData();

        $response = $this->withHeader('Authorization', 'Bearer '.$this->authenticate('owner@dys.com'))
            ->getJson('/api/reports?type=analytics')
            ->assertStatus(200)
            ->assertJson([
                'data' => [
                    'summary' => [
                        'total_sales' => 225000.0,
                        'total_expenses' => 117000.0,
                        'net_balance' => 108000.0,
                    ],
                ],
                'message' => 'Analytics report generated successfully.',
            ]);

        $charts = $response->json('data.charts');
        $this->assertIsArray($charts);
        $this->assertArrayHasKey('sales_trend', $charts);
        $this->assertArrayHasKey('expense_breakdown', $charts);
        $this->assertArrayHasKey('sector_comparison', $charts);
        // With seeded July data, sales_trend should have one month entry
        $this->assertNotEmpty($charts['sales_trend']);
        $this->assertEquals('2026-07', $charts['sales_trend'][0]['label']);
        $this->assertEquals(225000.0, (float) $charts['sales_trend'][0]['total']);
        $this->assertNotEmpty($charts['expense_breakdown']);
        $this->assertEquals('2026-07', $charts['expense_breakdown'][0]['label']);
        $this->assertEquals(117000.0, (float) $charts['expense_breakdown'][0]['total']);
        $this->assertCount(2, $charts['sector_comparison']);
    }

    public function test_employee_is_forbidden_from_reports(): void
    {
        $this->withHeader('Authorization', 'Bearer '.$this->authenticate('ana@dys.com'))
            ->getJson('/api/reports')
            ->assertStatus(403)
            ->assertJson([
                'message' => 'Forbidden.',
            ]);
    }

    public function test_invalid_report_type_returns_422(): void
    {
        $this->withHeader('Authorization', 'Bearer '.$this->authenticate('owner@dys.com'))
            ->getJson('/api/reports?type=bogus')
            ->assertStatus(422)
            ->assertJson([
                'errors' => [
                    'type' => ['The selected type is invalid.'],
                ],
            ]);
    }

    public function test_invalid_dates_and_sector_return_422(): void
    {
        $token = $this->authenticate('owner@dys.com');

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/reports?date_from=not-a-date')
            ->assertStatus(422)
            ->assertJson([
                'errors' => [
                    'date_from' => ['Invalid start date.'],
                ],
            ]);

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/reports?date_to=not-a-date')
            ->assertStatus(422)
            ->assertJson([
                'errors' => [
                    'date_to' => ['Invalid end date.'],
                ],
            ]);

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/reports?sector_id=999')
            ->assertStatus(422)
            ->assertJson([
                'errors' => [
                    'sector_id' => ['The selected sector_id is invalid.'],
                ],
            ]);
    }

    public function test_unauthenticated_requests_to_reports_return_401(): void
    {
        $this->getJson('/api/reports')->assertStatus(401)
            ->assertJson([
                'message' => 'Unauthenticated.',
            ]);
    }
}
