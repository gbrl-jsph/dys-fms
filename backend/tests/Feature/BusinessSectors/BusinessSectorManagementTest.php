<?php

namespace Tests\Feature\BusinessSectors;

use App\Models\BusinessSector;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class BusinessSectorManagementTest extends TestCase
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
            'description' => 'Souvenirs',
        ]);

        BusinessSector::create([
            'name' => 'Flavors by DYS',
            'description' => 'Grazing tables and celebration drinks',
        ]);

        BusinessSector::create([
            'name' => 'SnapDYS Memories',
            'description' => 'Video guestbook',
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

    public function test_business_owner_can_list_all_four_sectors(): void
    {
        $this->withHeader('Authorization', 'Bearer '.$this->authenticate('owner@dys.com'))
            ->getJson('/api/business-sectors')
            ->assertStatus(200)
            ->assertJson([
                'message' => 'Business sectors retrieved successfully.',
            ]);

        $response = $this->withHeader('Authorization', 'Bearer '.$this->authenticate('owner@dys.com'))
            ->getJson('/api/business-sectors');

        $this->assertCount(4, $response->json('data'));
        $this->assertEquals(['DYS Events', 'B&DYS', 'Flavors by DYS', 'SnapDYS Memories'], collect($response->json('data'))->pluck('name')->all());
        $this->assertTrue(collect($response->json('data'))->every(
            fn (array $sector) => isset($sector['id'], $sector['name'], $sector['description'])
        ));
    }

    public function test_event_manager_can_list_all_four_sectors(): void
    {
        $this->withHeader('Authorization', 'Bearer '.$this->authenticate('maria@dys.com'))
            ->getJson('/api/business-sectors')
            ->assertStatus(200)
            ->assertJson([
                'message' => 'Business sectors retrieved successfully.',
            ]);

        $response = $this->withHeader('Authorization', 'Bearer '.$this->authenticate('maria@dys.com'))
            ->getJson('/api/business-sectors');

        $this->assertCount(4, $response->json('data'));
    }

    public function test_employee_can_list_all_four_sectors(): void
    {
        $this->withHeader('Authorization', 'Bearer '.$this->authenticate('ana@dys.com'))
            ->getJson('/api/business-sectors')
            ->assertStatus(200)
            ->assertJson([
                'message' => 'Business sectors retrieved successfully.',
            ]);

        $response = $this->withHeader('Authorization', 'Bearer '.$this->authenticate('ana@dys.com'))
            ->getJson('/api/business-sectors');

        $this->assertCount(4, $response->json('data'));
    }

    public function test_business_owner_can_switch_sector(): void
    {
        $this->withHeader('Authorization', 'Bearer '.$this->authenticate('owner@dys.com'))
            ->postJson('/api/business-sectors/switch', [
                'sector_id' => $this->bandysSector->id,
                'previous_sector_id' => $this->eventsSector->id,
            ])
            ->assertStatus(200)
            ->assertJson([
                'data' => [
                    'previous_sector' => [
                        'id' => $this->eventsSector->id,
                        'name' => 'DYS Events',
                    ],
                    'current_sector' => [
                        'id' => $this->bandysSector->id,
                        'name' => 'B&DYS',
                    ],
                ],
                'message' => 'Sector switched successfully.',
            ]);
    }

    public function test_switch_without_previous_sector_id_returns_null_previous(): void
    {
        $this->withHeader('Authorization', 'Bearer '.$this->authenticate('owner@dys.com'))
            ->postJson('/api/business-sectors/switch', [
                'sector_id' => $this->bandysSector->id,
            ])
            ->assertStatus(200)
            ->assertJson([
                'data' => [
                    'previous_sector' => null,
                    'current_sector' => [
                        'id' => $this->bandysSector->id,
                        'name' => 'B&DYS',
                    ],
                ],
                'message' => 'Sector switched successfully.',
            ]);
    }

    public function test_event_manager_cannot_switch_sector(): void
    {
        $this->withHeader('Authorization', 'Bearer '.$this->authenticate('maria@dys.com'))
            ->postJson('/api/business-sectors/switch', [
                'sector_id' => $this->eventsSector->id,
                'previous_sector_id' => $this->bandysSector->id,
            ])
            ->assertStatus(403)
            ->assertJson([
                'message' => 'Forbidden.',
            ]);
    }

    public function test_employee_cannot_switch_sector(): void
    {
        $this->withHeader('Authorization', 'Bearer '.$this->authenticate('ana@dys.com'))
            ->postJson('/api/business-sectors/switch', [
                'sector_id' => $this->bandysSector->id,
                'previous_sector_id' => $this->eventsSector->id,
            ])
            ->assertStatus(403)
            ->assertJson([
                'message' => 'Forbidden.',
            ]);
    }

    public function test_switch_requires_an_existing_sector_id(): void
    {
        $token = $this->authenticate('owner@dys.com');

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/business-sectors/switch', [])
            ->assertStatus(422)
            ->assertJson([
                'errors' => [
                    'sector_id' => ['Sector is required.'],
                ],
            ]);

        $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/business-sectors/switch', [
                'sector_id' => 999,
            ])
            ->assertStatus(422)
            ->assertJson([
                'errors' => [
                    'sector_id' => ['The selected sector_id is invalid.'],
                ],
            ]);
    }

    public function test_switch_rejects_invalid_previous_sector_id(): void
    {
        $this->withHeader('Authorization', 'Bearer '.$this->authenticate('owner@dys.com'))
            ->postJson('/api/business-sectors/switch', [
                'sector_id' => $this->bandysSector->id,
                'previous_sector_id' => 999,
            ])
            ->assertStatus(422)
            ->assertJson([
                'errors' => [
                    'previous_sector_id' => ['The selected previous_sector_id is invalid.'],
                ],
            ]);
    }

    public function test_switch_does_not_modify_any_sector_data(): void
    {
        $this->withHeader('Authorization', 'Bearer '.$this->authenticate('owner@dys.com'))
            ->postJson('/api/business-sectors/switch', [
                'sector_id' => $this->bandysSector->id,
                'previous_sector_id' => $this->eventsSector->id,
            ])->assertStatus(200);

        $this->assertDatabaseHas('business_sectors', [
            'id' => $this->eventsSector->id,
            'name' => 'DYS Events',
        ]);
        $this->assertDatabaseHas('business_sectors', [
            'id' => $this->bandysSector->id,
            'name' => 'B&DYS',
        ]);
    }

    public function test_unauthenticated_requests_to_sector_endpoints_return_401(): void
    {
        $this->getJson('/api/business-sectors')->assertStatus(401)
            ->assertJson([
                'message' => 'Unauthenticated.',
            ]);

        $this->postJson('/api/business-sectors/switch', [
            'sector_id' => $this->bandysSector->id,
        ])->assertStatus(401)
            ->assertJson([
                'message' => 'Unauthenticated.',
            ]);
    }
}
