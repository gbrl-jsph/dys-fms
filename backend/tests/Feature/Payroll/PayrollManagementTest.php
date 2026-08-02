<?php

namespace Tests\Feature\Payroll;

use App\Models\BusinessSector;
use App\Models\Expense;
use App\Models\PayrollRecord;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class PayrollManagementTest extends TestCase
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

    private function ownerToken(): string
    {
        return $this->authenticate('owner@dys.com');
    }

    private function createPayroll(int $userId, int $sectorId, float $hours, float $rate, string $payPeriod, string $calculatedAt, int $expenseUserId): PayrollRecord
    {
        $computedSalary = $hours * $rate;

        $record = new PayrollRecord([
            'user_id' => $userId,
            'sector_id' => $sectorId,
            'hours_worked' => $hours,
            'hourly_rate' => $rate,
            'computed_salary' => $computedSalary,
            'pay_period' => $payPeriod,
        ]);
        $record->calculated_at = $calculatedAt;
        $record->save();

        $expense = new Expense([
            'user_id' => $expenseUserId,
            'sector_id' => $sectorId,
            'amount' => $computedSalary,
            'description' => "Payroll — {$record->user->name} — {$payPeriod}",
            'payroll_record_id' => $record->id,
        ]);
        $expense->recorded_at = $calculatedAt;
        $expense->save();

        return $record;
    }

    public function test_owner_calculates_payroll_and_expense_is_auto_created(): void
    {
        $response = $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->postJson('/api/payroll', [
                'user_id' => $this->ana->id,
                'hours_worked' => 160.00,
                'hourly_rate' => 125.00,
                'pay_period' => '2026-07-15',
            ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'employee' => ['id', 'name'],
                    'sector' => ['id', 'name'],
                    'hours_worked',
                    'hourly_rate',
                    'computed_salary',
                    'pay_period',
                    'calculated_at',
                    'expense' => ['id', 'amount', 'description'],
                ],
                'message',
            ])
            ->assertJson([
                'data' => [
                    'employee' => [
                        'id' => $this->ana->id,
                        'name' => 'Ana Reyes',
                    ],
                    'sector' => [
                        'id' => $this->eventsSector->id,
                        'name' => 'DYS Events',
                    ],
                    'hours_worked' => 160.0,
                    'hourly_rate' => 125.0,
                    'computed_salary' => 20000.0,
                    'pay_period' => '2026-07-15',
                    'expense' => [
                        'amount' => 20000.0,
                        'description' => 'Payroll — Ana Reyes — 2026-07-15',
                    ],
                ],
                'message' => 'Payroll calculated and saved successfully. Expense record auto-created.',
            ]);

        $this->assertDatabaseHas('payroll_records', [
            'user_id' => $this->ana->id,
            'sector_id' => $this->eventsSector->id,
            'hours_worked' => 160.00,
            'hourly_rate' => 125.00,
            'computed_salary' => 20000.00,
            'pay_period' => '2026-07-15',
        ]);

        $this->assertDatabaseHas('expenses', [
            'user_id' => $this->owner->id,
            'sector_id' => $this->eventsSector->id,
            'amount' => 20000.00,
            'description' => 'Payroll — Ana Reyes — 2026-07-15',
            'payroll_record_id' => $response->json('data.id'),
        ]);
    }

    public function test_owner_can_calculate_payroll_for_event_manager(): void
    {
        $response = $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->postJson('/api/payroll', [
                'user_id' => $this->maria->id,
                'hours_worked' => 80.00,
                'hourly_rate' => 150.00,
                'pay_period' => '2026-07-15',
            ]);

        $response->assertStatus(201)
            ->assertJson([
                'data' => [
                    'employee' => ['id' => $this->maria->id],
                    'sector' => ['id' => $this->bandysSector->id],
                    'computed_salary' => 12000.0,
                ],
            ]);

        $this->assertDatabaseHas('expenses', [
            'sector_id' => $this->bandysSector->id,
            'amount' => 12000.00,
            'payroll_record_id' => $response->json('data.id'),
        ]);
    }

    public function test_invalid_hours_worked_return_422_without_persisting(): void
    {
        $token = $this->ownerToken();

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/payroll', [
                'user_id' => $this->ana->id,
                'hours_worked' => 0,
                'hourly_rate' => 125.00,
                'pay_period' => '2026-07-15',
            ])->assertStatus(422)
            ->assertJson([
                'errors' => [
                    'hours_worked' => ['Hours worked must be a positive number.'],
                ],
            ]);

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/payroll', [
                'user_id' => $this->ana->id,
                'hourly_rate' => 125.00,
                'pay_period' => '2026-07-15',
            ])->assertStatus(422)
            ->assertJson([
                'errors' => [
                    'hours_worked' => ['Hours worked is required.'],
                ],
            ]);

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/payroll', [
                'user_id' => $this->ana->id,
                'hours_worked' => 100000000,
                'hourly_rate' => 125.00,
                'pay_period' => '2026-07-15',
            ])->assertStatus(422)
            ->assertJson([
                'errors' => [
                    'hours_worked' => ['Hours worked must not exceed 99999999.99.'],
                ],
            ]);

        $this->assertDatabaseCount('payroll_records', 0);
        $this->assertDatabaseCount('expenses', 0);
    }

    public function test_invalid_hourly_rate_return_422_without_persisting(): void
    {
        $token = $this->ownerToken();

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/payroll', [
                'user_id' => $this->ana->id,
                'hours_worked' => 160.00,
                'hourly_rate' => -50,
                'pay_period' => '2026-07-15',
            ])->assertStatus(422)
            ->assertJson([
                'errors' => [
                    'hourly_rate' => ['Hourly rate must be a positive number.'],
                ],
            ]);

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/payroll', [
                'user_id' => $this->ana->id,
                'hours_worked' => 160.00,
                'pay_period' => '2026-07-15',
            ])->assertStatus(422)
            ->assertJson([
                'errors' => [
                    'hourly_rate' => ['Hourly rate is required.'],
                ],
            ]);

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/payroll', [
                'user_id' => $this->ana->id,
                'hours_worked' => 160.00,
                'hourly_rate' => 100000000,
                'pay_period' => '2026-07-15',
            ])->assertStatus(422)
            ->assertJson([
                'errors' => [
                    'hourly_rate' => ['Hourly rate must not exceed 99999999.99.'],
                ],
            ]);

        $this->assertDatabaseCount('payroll_records', 0);
    }

    public function test_invalid_pay_period_return_422(): void
    {
        $token = $this->ownerToken();

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/payroll', [
                'user_id' => $this->ana->id,
                'hours_worked' => 160.00,
                'hourly_rate' => 125.00,
            ])->assertStatus(422)
            ->assertJson([
                'errors' => [
                    'pay_period' => ['Pay period is required.'],
                ],
            ]);

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/payroll', [
                'user_id' => $this->ana->id,
                'hours_worked' => 160.00,
                'hourly_rate' => 125.00,
                'pay_period' => 'not-a-date',
            ])->assertStatus(422)
            ->assertJson([
                'errors' => [
                    'pay_period' => ['Pay period must be a valid date.'],
                ],
            ]);

        $this->assertDatabaseCount('payroll_records', 0);
        $this->assertDatabaseCount('expenses', 0);
    }

    public function test_cannot_calculate_payroll_for_business_owner(): void
    {
        $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->postJson('/api/payroll', [
                'user_id' => $this->owner->id,
                'hours_worked' => 160.00,
                'hourly_rate' => 125.00,
                'pay_period' => '2026-07-15',
            ])->assertStatus(422)
            ->assertJson([
                'errors' => [
                    'user_id' => ['Payroll cannot be calculated for the Business Owner.'],
                ],
            ]);

        $this->assertDatabaseCount('payroll_records', 0);
        $this->assertDatabaseCount('expenses', 0);
    }

    public function test_cannot_calculate_payroll_for_missing_employee(): void
    {
        $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->postJson('/api/payroll', [
                'user_id' => 999,
                'hours_worked' => 160.00,
                'hourly_rate' => 125.00,
                'pay_period' => '2026-07-15',
            ])->assertStatus(422)
            ->assertJson([
                'errors' => [
                    'user_id' => ['The selected user_id is invalid.'],
                ],
            ]);

        $this->assertDatabaseCount('payroll_records', 0);
    }

    public function test_event_manager_and_employee_cannot_calculate_payroll(): void
    {
        $emToken = $this->authenticate('maria@dys.com');
        $eeToken = $this->authenticate('ana@dys.com');

        $payload = [
            'user_id' => $this->ana->id,
            'hours_worked' => 160.00,
            'hourly_rate' => 125.00,
            'pay_period' => '2026-07-15',
        ];

        $this->withHeader('Authorization', 'Bearer '.$emToken)
            ->postJson('/api/payroll', $payload)
            ->assertStatus(403)
            ->assertJson([
                'message' => 'Forbidden.',
            ]);

        $this->withHeader('Authorization', 'Bearer '.$eeToken)
            ->postJson('/api/payroll', $payload)
            ->assertStatus(403)
            ->assertJson([
                'message' => 'Forbidden.',
            ]);

        $this->assertDatabaseCount('payroll_records', 0);
        $this->assertDatabaseCount('expenses', 0);
    }

    public function test_event_manager_views_only_own_payroll_ignoring_filters(): void
    {
        $this->createPayroll($this->ana->id, $this->eventsSector->id, 160.00, 125.00, '2026-07-15', '2026-07-15 10:00:00', $this->owner->id);
        $this->createPayroll($this->maria->id, $this->bandysSector->id, 80.00, 150.00, '2026-07-15', '2026-07-16 10:00:00', $this->owner->id);
        $this->createPayroll($this->maria->id, $this->bandysSector->id, 90.00, 150.00, '2026-07-31', '2026-07-31 10:00:00', $this->owner->id);

        $token = $this->authenticate('maria@dys.com');

        $own = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/payroll')
            ->assertStatus(200)
            ->assertJson([
                'meta' => [
                    'total' => 2,
                ],
            ]);

        $this->assertCount(2, $own->json('data'));
        $this->assertTrue(collect($own->json('data'))->every(
            fn (array $record) => $record['employee']['id'] === $this->maria->id
        ));

        $filtered = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/payroll?sector_id='.$this->eventsSector->id.'&user_id='.$this->ana->id)
            ->assertStatus(200);

        $this->assertCount(2, $filtered->json('data'));
        $this->assertTrue(collect($filtered->json('data'))->every(
            fn (array $record) => $record['employee']['id'] === $this->maria->id
        ));
    }

    public function test_employee_views_only_own_payroll(): void
    {
        $this->createPayroll($this->ana->id, $this->eventsSector->id, 160.00, 125.00, '2026-07-15', '2026-07-15 10:00:00', $this->owner->id);
        $this->createPayroll($this->maria->id, $this->bandysSector->id, 80.00, 150.00, '2026-07-15', '2026-07-16 10:00:00', $this->owner->id);

        $token = $this->authenticate('ana@dys.com');

        $own = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/payroll')
            ->assertStatus(200)
            ->assertJson([
                'meta' => [
                    'total' => 1,
                ],
            ]);

        $this->assertCount(1, $own->json('data'));
        $this->assertEquals($this->ana->id, $own->json('data.0.employee.id'));
    }

    public function test_owner_views_all_payroll_with_sector_and_employee_filters(): void
    {
        $this->createPayroll($this->ana->id, $this->eventsSector->id, 160.00, 125.00, '2026-07-15', '2026-07-15 10:00:00', $this->owner->id);
        $this->createPayroll($this->maria->id, $this->bandysSector->id, 80.00, 150.00, '2026-07-15', '2026-07-16 10:00:00', $this->owner->id);
        $this->createPayroll($this->maria->id, $this->bandysSector->id, 90.00, 150.00, '2026-07-31', '2026-07-31 10:00:00', $this->owner->id);

        $token = $this->ownerToken();

        $all = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/payroll')
            ->assertStatus(200)
            ->assertJson([
                'meta' => [
                    'total' => 3,
                ],
                'message' => 'Payroll records retrieved successfully.',
            ]);

        $this->assertCount(3, $all->json('data'));
        $this->assertNotNull($all->json('data.0.expense.id'));
        $this->assertNotNull($all->json('data.0.expense.amount'));

        $bySector = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/payroll?sector_id='.$this->bandysSector->id)
            ->assertStatus(200);

        $this->assertCount(2, $bySector->json('data'));
        $this->assertTrue(collect($bySector->json('data'))->every(
            fn (array $record) => $record['sector']['id'] === $this->bandysSector->id
        ));

        $byEmployee = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/payroll?user_id='.$this->ana->id)
            ->assertStatus(200);

        $this->assertCount(1, $byEmployee->json('data'));
        $this->assertEquals($this->ana->id, $byEmployee->json('data.0.employee.id'));
    }

    public function test_payroll_results_are_ordered_by_calculated_at_desc(): void
    {
        $this->createPayroll($this->ana->id, $this->eventsSector->id, 100.00, 100.00, '2026-07-01', '2026-07-01 10:00:00', $this->owner->id);
        $this->createPayroll($this->ana->id, $this->eventsSector->id, 120.00, 100.00, '2026-07-15', '2026-07-15 10:00:00', $this->owner->id);
        $this->createPayroll($this->ana->id, $this->eventsSector->id, 130.00, 100.00, '2026-07-31', '2026-07-31 10:00:00', $this->owner->id);

        $token = $this->ownerToken();

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/payroll?user_id='.$this->ana->id)
            ->assertStatus(200);

        $this->assertEquals(
            ['2026-07-31', '2026-07-15', '2026-07-01'],
            collect($response->json('data'))->pluck('pay_period')->all()
        );
    }

    public function test_pagination_parameters_are_respected(): void
    {
        for ($i = 1; $i <= 5; $i++) {
            $this->createPayroll($this->ana->id, $this->eventsSector->id, 100.00, 100.00, sprintf('2026-06-%02d', $i), sprintf('2026-06-%02d 10:00:00', $i), $this->owner->id);
        }

        $token = $this->ownerToken();

        $pageOne = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/payroll?user_id='.$this->ana->id.'&per_page=2&page=1')
            ->assertStatus(200)
            ->assertJson([
                'meta' => [
                    'current_page' => 1,
                    'per_page' => 2,
                    'total' => 5,
                    'last_page' => 3,
                ],
            ]);

        $this->assertCount(2, $pageOne->json('data'));

        $pageThree = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/payroll?user_id='.$this->ana->id.'&per_page=2&page=3')
            ->assertStatus(200);

        $this->assertCount(1, $pageThree->json('data'));
    }

    public function test_transaction_rolls_back_when_expense_creation_fails(): void
    {
        Expense::saving(function () {
            throw new \RuntimeException('Forced expense failure');
        });

        $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->postJson('/api/payroll', [
                'user_id' => $this->ana->id,
                'hours_worked' => 160.00,
                'hourly_rate' => 125.00,
                'pay_period' => '2026-07-15',
            ])->assertStatus(500);

        Expense::flushEventListeners();

        $this->assertDatabaseCount('payroll_records', 0);
        $this->assertDatabaseCount('expenses', 0);
    }

    public function test_unauthenticated_requests_to_payroll_endpoints_return_401(): void
    {
        $this->getJson('/api/payroll')->assertStatus(401)
            ->assertJson([
                'message' => 'Unauthenticated.',
            ]);

        $this->postJson('/api/payroll', [
            'user_id' => 3,
            'hours_worked' => 160.00,
            'hourly_rate' => 125.00,
            'pay_period' => '2026-07-15',
        ])->assertStatus(401)
            ->assertJson([
                'message' => 'Unauthenticated.',
            ]);
    }
}
