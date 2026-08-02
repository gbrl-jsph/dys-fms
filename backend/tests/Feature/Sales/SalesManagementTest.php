<?php

namespace Tests\Feature\Sales;

use App\Models\BusinessSector;
use App\Models\SalesTransaction;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class SalesManagementTest extends TestCase
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

    private function createSale(int $sectorId, float $amount, string $description, string $recordedAt, int $userId): SalesTransaction
    {
        $transaction = new SalesTransaction([
            'user_id' => $userId,
            'sector_id' => $sectorId,
            'amount' => $amount,
            'description' => $description,
        ]);
        $transaction->recorded_at = $recordedAt;
        $transaction->save();

        return $transaction;
    }

    public function test_owner_can_record_sale_and_it_appears_in_the_list(): void
    {
        $response = $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->postJson('/api/sales', [
                'amount' => 15000.00,
                'description' => 'Full event coordination package',
                'sector_id' => $this->eventsSector->id,
            ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'amount',
                    'description',
                    'recorded_by' => ['id', 'name'],
                    'sector' => ['id', 'name'],
                    'recorded_at',
                ],
                'message',
            ])
            ->assertJson([
                'data' => [
                    'amount' => 15000.0,
                    'description' => 'Full event coordination package',
                    'recorded_by' => [
                        'id' => $this->owner->id,
                        'name' => 'Juan Dela Cruz',
                    ],
                    'sector' => [
                        'id' => $this->eventsSector->id,
                        'name' => 'DYS Events',
                    ],
                ],
                'message' => 'Sale recorded successfully.',
            ]);

        $this->assertDatabaseHas('sales_transactions', [
            'user_id' => $this->owner->id,
            'sector_id' => $this->eventsSector->id,
            'amount' => 15000.00,
            'description' => 'Full event coordination package',
        ]);

        $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->getJson('/api/sales?sector_id='.$this->eventsSector->id)
            ->assertStatus(200)
            ->assertJson([
                'data' => [[
                    'id' => $response->json('data.id'),
                    'recorded_by' => ['id' => $this->owner->id],
                    'sector' => ['id' => $this->eventsSector->id],
                ]],
                'message' => 'Sales transactions retrieved successfully.',
            ]);
    }

    public function test_event_manager_sale_sector_is_always_overridden_to_assigned(): void
    {
        $token = $this->authenticate('maria@dys.com');

        $withoutSector = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/sales', [
                'amount' => 8500.00,
                'description' => 'Souvenir package',
            ]);

        $withoutSector->assertStatus(201)
            ->assertJson([
                'data' => [
                    'amount' => 8500.0,
                    'description' => 'Souvenir package',
                    'recorded_by' => [
                        'id' => $this->maria->id,
                        'name' => 'Maria Santos',
                    ],
                    'sector' => [
                        'id' => $this->bandysSector->id,
                        'name' => 'B&DYS',
                    ],
                ],
                'message' => 'Sale recorded successfully.',
            ]);

        $this->assertDatabaseHas('sales_transactions', [
            'user_id' => $this->maria->id,
            'sector_id' => $this->bandysSector->id,
            'amount' => 8500.00,
        ]);

        $withWrongSector = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/sales', [
                'amount' => 1200.00,
                'description' => 'Client-provided sector ignored',
                'sector_id' => $this->eventsSector->id,
            ]);

        $withWrongSector->assertStatus(201)
            ->assertJson([
                'data' => [
                    'sector' => [
                        'id' => $this->bandysSector->id,
                        'name' => 'B&DYS',
                    ],
                ],
            ]);

        $this->assertDatabaseHas('sales_transactions', [
            'user_id' => $this->maria->id,
            'sector_id' => $this->bandysSector->id,
            'amount' => 1200.00,
        ]);
    }

    public function test_owner_can_record_sale_without_description(): void
    {
        $response = $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->postJson('/api/sales', [
                'amount' => 500.00,
                'sector_id' => $this->bandysSector->id,
            ]);

        $response->assertStatus(201)
            ->assertJson([
                'data' => [
                    'description' => null,
                    'sector' => ['id' => $this->bandysSector->id],
                ],
            ]);
    }

    public function test_invalid_amounts_return_422_without_persisting(): void
    {
        $token = $this->ownerToken();

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/sales', [
                'amount' => 0,
                'description' => 'Zero',
                'sector_id' => $this->eventsSector->id,
            ])->assertStatus(422)
            ->assertJson([
                'message' => 'Amount must be a positive number.',
                'errors' => [
                    'amount' => ['Amount must be a positive number.'],
                ],
            ]);

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/sales', [
                'amount' => -100,
                'description' => 'Negative',
                'sector_id' => $this->eventsSector->id,
            ])->assertStatus(422)
            ->assertJson([
                'errors' => [
                    'amount' => ['Amount must be a positive number.'],
                ],
            ]);

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/sales', [
                'description' => 'Missing amount',
                'sector_id' => $this->eventsSector->id,
            ])->assertStatus(422)
            ->assertJson([
                'errors' => [
                    'amount' => ['Amount is required.'],
                ],
            ]);

        $this->assertDatabaseCount('sales_transactions', 0);
    }

    public function test_owner_must_provide_a_valid_sector_id(): void
    {
        $token = $this->ownerToken();

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/sales', [
                'amount' => 1000.00,
            ])->assertStatus(422)
            ->assertJson([
                'errors' => [
                    'sector_id' => ['Sector is required.'],
                ],
            ]);

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/sales', [
                'amount' => 1000.00,
                'sector_id' => 999,
            ])->assertStatus(422)
            ->assertJson([
                'errors' => [
                    'sector_id' => ['The selected sector_id is invalid.'],
                ],
            ]);

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/sales')
            ->assertStatus(422)
            ->assertJson([
                'errors' => [
                    'sector_id' => ['Sector is required.'],
                ],
            ]);

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/sales?sector_id=999')
            ->assertStatus(422)
            ->assertJson([
                'errors' => [
                    'sector_id' => ['The selected sector_id is invalid.'],
                ],
            ]);
    }

    public function test_employee_is_forbidden_from_sales_endpoints(): void
    {
        $token = $this->authenticate('ana@dys.com');

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/sales', [
                'amount' => 5000.00,
                'description' => 'Employee attempt',
            ])->assertStatus(403)
            ->assertJson([
                'message' => 'Forbidden.',
            ]);

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/sales')
            ->assertStatus(403)
            ->assertJson([
                'message' => 'Forbidden.',
            ]);

        $this->assertDatabaseCount('sales_transactions', 0);
    }

    public function test_sector_scoping_filters_owner_results_and_orders_by_recorded_at_desc(): void
    {
        $this->createSale($this->eventsSector->id, 1000.00, 'Events first', '2026-07-01 10:00:00', $this->owner->id);
        $this->createSale($this->bandysSector->id, 2000.00, 'B&DYS second', '2026-07-02 10:00:00', $this->owner->id);
        $this->createSale($this->eventsSector->id, 3000.00, 'Events third', '2026-07-03 10:00:00', $this->owner->id);
        $this->createSale($this->bandysSector->id, 4000.00, 'B&DYS fourth', '2026-07-04 10:00:00', $this->owner->id);

        $token = $this->ownerToken();

        $events = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/sales?sector_id='.$this->eventsSector->id)
            ->assertStatus(200)
            ->assertJson([
                'meta' => [
                    'current_page' => 1,
                    'per_page' => 15,
                    'total' => 2,
                    'last_page' => 1,
                ],
                'message' => 'Sales transactions retrieved successfully.',
            ]);

        $this->assertCount(2, $events->json('data'));
        $this->assertEquals(['Events third', 'Events first'], collect($events->json('data'))->pluck('description')->all());

        $bandys = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/sales?sector_id='.$this->bandysSector->id)
            ->assertStatus(200);

        $this->assertCount(2, $bandys->json('data'));
        $this->assertEquals(['B&DYS fourth', 'B&DYS second'], collect($bandys->json('data'))->pluck('description')->all());
    }

    public function test_event_manager_list_is_scoped_to_assigned_sector_ignoring_sector_id(): void
    {
        $this->createSale($this->eventsSector->id, 1000.00, 'Events sale', '2026-07-01 10:00:00', $this->owner->id);
        $this->createSale($this->bandysSector->id, 2000.00, 'B&DYS sale one', '2026-07-02 10:00:00', $this->owner->id);
        $this->createSale($this->bandysSector->id, 3000.00, 'B&DYS sale two', '2026-07-03 10:00:00', $this->maria->id);

        $token = $this->authenticate('maria@dys.com');

        $assigned = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/sales')
            ->assertStatus(200)
            ->assertJson([
                'meta' => [
                    'total' => 2,
                ],
            ]);

        $this->assertCount(2, $assigned->json('data'));
        $this->assertTrue(collect($assigned->json('data'))->every(
            fn (array $sale) => $sale['sector']['id'] === $this->bandysSector->id
        ));
        $this->assertEquals(
            ['B&DYS sale two', 'B&DYS sale one'],
            collect($assigned->json('data'))->pluck('description')->all()
        );

        $overridden = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/sales?sector_id='.$this->eventsSector->id)
            ->assertStatus(200);

        $this->assertCount(2, $overridden->json('data'));
        $this->assertTrue(collect($overridden->json('data'))->every(
            fn (array $sale) => $sale['sector']['id'] === $this->bandysSector->id
        ));
    }

    public function test_pagination_parameters_are_respected(): void
    {
        for ($i = 1; $i <= 5; $i++) {
            $this->createSale($this->eventsSector->id, $i * 1000.00, "Sale {$i}", sprintf('2026-07-%02d 10:00:00', $i), $this->owner->id);
        }

        $token = $this->ownerToken();

        $pageOne = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/sales?sector_id='.$this->eventsSector->id.'&per_page=2&page=1')
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
            ->getJson('/api/sales?sector_id='.$this->eventsSector->id.'&per_page=2&page=3')
            ->assertStatus(200);

        $this->assertCount(1, $pageThree->json('data'));
    }

    public function test_unauthenticated_requests_to_sales_endpoints_return_401(): void
    {
        $this->getJson('/api/sales')->assertStatus(401)
            ->assertJson([
                'message' => 'Unauthenticated.',
            ]);

        $this->postJson('/api/sales', [
            'amount' => 1000.00,
            'sector_id' => $this->eventsSector->id,
        ])->assertStatus(401)
            ->assertJson([
                'message' => 'Unauthenticated.',
            ]);
    }
}
