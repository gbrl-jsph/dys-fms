<?php

namespace Tests\Feature\User;

use App\Mail\TemporaryPasswordMail;
use App\Models\User;
use App\Models\BusinessSector;
use App\Services\UserService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Symfony\Component\HttpKernel\Exception\HttpException;
use Tests\TestCase;

class UserManagementTest extends TestCase
{
    use RefreshDatabase;

    private BusinessSector $eventsSector;

    private BusinessSector $bandysSector;

    private User $owner;

    private User $maria;

    private User $ana;

    private User $leo;

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

        $this->leo = User::create([
            'name' => 'Leo Cruz',
            'email' => 'leo@dys.com',
            'password' => Hash::make('SecurePass123'),
            'role' => 'Employee/Staff',
            'sector_id' => $this->eventsSector->id,
            'account_status' => 'Inactive',
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

    public function test_owner_can_create_event_manager_with_temporary_password_that_allows_first_login(): void
    {
        $response = $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->postJson('/api/users', [
                'name' => 'Rosa Martinez',
                'email' => 'rosa@dys.com',
                'role' => 'Event Manager',
                'sector_id' => $this->eventsSector->id,
            ]);

        $response->assertStatus(201)
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'name',
                    'email',
                    'role',
                    'sector_id',
                    'account_status',
                    'temporary_password',
                    'created_at',
                ],
                'message',
            ])
            ->assertJson([
                'data' => [
                    'name' => 'Rosa Martinez',
                    'email' => 'rosa@dys.com',
                    'role' => 'Event Manager',
                    'sector_id' => $this->eventsSector->id,
                    'account_status' => 'Active',
                ],
                'message' => 'User account created successfully.',
            ]);

        $temporaryPassword = $response->json('data.temporary_password');
        $this->assertIsString($temporaryPassword);
        $this->assertGreaterThanOrEqual(8, strlen($temporaryPassword));
        $this->assertMatchesRegularExpression('/[A-Z]/', $temporaryPassword);
        $this->assertMatchesRegularExpression('/[a-z]/', $temporaryPassword);
        $this->assertMatchesRegularExpression('/[0-9]/', $temporaryPassword);
        $this->assertMatchesRegularExpression('/[^A-Za-z0-9]/', $temporaryPassword);

        $this->postJson('/api/login', [
            'email' => 'rosa@dys.com',
            'password' => $temporaryPassword,
        ])->assertStatus(200)
            ->assertJson([
                'data' => [
                    'user' => [
                        'role' => 'Event Manager',
                        'sector_id' => $this->eventsSector->id,
                        'account_status' => 'Active',
                    ],
                    'default_sector' => [
                        'id' => $this->eventsSector->id,
                    ],
                ],
            ]);
    }

    public function test_owner_can_create_employee_with_temporary_password_that_allows_first_login(): void
    {
        $response = $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->postJson('/api/users', [
                'name' => 'Paolo Gomez',
                'email' => 'paolo@dys.com',
                'role' => 'Employee/Staff',
                'sector_id' => $this->bandysSector->id,
            ]);

        $response->assertStatus(201)
            ->assertJson([
                'data' => [
                    'name' => 'Paolo Gomez',
                    'email' => 'paolo@dys.com',
                    'role' => 'Employee/Staff',
                    'sector_id' => $this->bandysSector->id,
                    'account_status' => 'Active',
                ],
                'message' => 'User account created successfully.',
            ]);

        $temporaryPassword = $response->json('data.temporary_password');
        $this->assertGreaterThanOrEqual(8, strlen($temporaryPassword));

        $this->postJson('/api/login', [
            'email' => 'paolo@dys.com',
            'password' => $temporaryPassword,
        ])->assertStatus(200)
            ->assertJson([
                'data' => [
                    'user' => [
                        'role' => 'Employee/Staff',
                        'sector_id' => $this->bandysSector->id,
                        'account_status' => 'Active',
                    ],
                    'default_sector' => [
                        'id' => $this->bandysSector->id,
                    ],
                ],
            ]);
    }

    public function test_creating_user_with_duplicate_email_returns_422(): void
    {
        $response = $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->postJson('/api/users', [
                'name' => 'Duplicate User',
                'email' => 'maria@dys.com',
                'role' => 'Event Manager',
                'sector_id' => $this->eventsSector->id,
            ]);

        $response->assertStatus(422)
            ->assertJson([
                'message' => 'Email has already been taken.',
                'errors' => [
                    'email' => ['Email has already been taken.'],
                ],
            ]);

        $this->assertDatabaseCount('users', 4);
    }

    public function test_creating_user_with_invalid_role_returns_422(): void
    {
        $response = $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->postJson('/api/users', [
                'name' => 'Bad Role',
                'email' => 'badrole@dys.com',
                'role' => 'Business Owner',
                'sector_id' => $this->eventsSector->id,
            ]);

        $response->assertStatus(422)
            ->assertJson([
                'message' => 'The selected role is invalid.',
                'errors' => [
                    'role' => ['The selected role is invalid.'],
                ],
            ]);
    }

    public function test_owner_can_update_user_and_new_credentials_work(): void
    {
        $response = $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->putJson("/api/users/{$this->maria->id}", [
                'name' => 'Maria Santos Updated',
                'email' => 'maria.updated@dys.com',
                'role' => 'Employee/Staff',
                'sector_id' => $this->eventsSector->id,
            ]);

        $response->assertStatus(200)
            ->assertJson([
                'data' => [
                    'id' => $this->maria->id,
                    'name' => 'Maria Santos Updated',
                    'email' => 'maria.updated@dys.com',
                    'role' => 'Employee/Staff',
                    'sector_id' => $this->eventsSector->id,
                    'account_status' => 'Active',
                ],
                'message' => 'User updated successfully.',
            ]);

        $this->postJson('/api/login', [
            'email' => 'maria@dys.com',
            'password' => 'SecurePass123',
        ])->assertStatus(401);

        $this->postJson('/api/login', [
            'email' => 'maria.updated@dys.com',
            'password' => 'SecurePass123',
        ])->assertStatus(200)
            ->assertJson([
                'data' => [
                    'user' => [
                        'name' => 'Maria Santos Updated',
                        'role' => 'Employee/Staff',
                    ],
                    'default_sector' => [
                        'id' => $this->eventsSector->id,
                    ],
                ],
            ]);
    }

    public function test_owner_can_deactivate_and_reactivate_user(): void
    {
        $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->patchJson("/api/users/{$this->maria->id}/status", [
                'account_status' => 'Inactive',
            ])->assertStatus(200)
            ->assertJson([
                'data' => [
                    'id' => $this->maria->id,
                    'account_status' => 'Inactive',
                ],
                'message' => 'User status updated successfully.',
            ]);

        $this->postJson('/api/login', [
            'email' => 'maria@dys.com',
            'password' => 'SecurePass123',
        ])->assertStatus(401)
            ->assertJson([
                'message' => 'Invalid username or password.',
            ]);

        $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->patchJson("/api/users/{$this->maria->id}/status", [
                'account_status' => 'Active',
            ])->assertStatus(200)
            ->assertJson([
                'data' => [
                    'id' => $this->maria->id,
                    'account_status' => 'Active',
                ],
            ]);

        $this->postJson('/api/login', [
            'email' => 'maria@dys.com',
            'password' => 'SecurePass123',
        ])->assertStatus(200);
    }

    public function test_non_owner_roles_are_forbidden_from_all_user_endpoints(): void
    {
        $endpoints = [
            ['getJson', '/api/users', []],
            ['getJson', "/api/users/{$this->maria->id}", []],
            ['postJson', '/api/users', [
                'name' => 'Blocked User',
                'email' => 'blocked@dys.com',
                'role' => 'Event Manager',
                'sector_id' => $this->eventsSector->id,
            ]],
            ['putJson', "/api/users/{$this->maria->id}", [
                'name' => 'Blocked User',
                'email' => 'maria@dys.com',
                'role' => 'Event Manager',
                'sector_id' => $this->eventsSector->id,
            ]],
            ['patchJson', "/api/users/{$this->maria->id}/status", [
                'account_status' => 'Inactive',
            ]],
            ['postJson', "/api/users/{$this->maria->id}/reset-password", []],
        ];

        $nonOwners = [
            'maria@dys.com' => 'Event Manager',
            'ana@dys.com' => 'Employee/Staff',
        ];

        foreach ($nonOwners as $email => $role) {
            $token = $this->authenticate($email);

            foreach ($endpoints as [$method, $uri, $body]) {
                $this->withHeader('Authorization', 'Bearer '.$token)
                    ->{$method}($uri, $body)
                    ->assertStatus(403)
                    ->assertJson([
                        'message' => 'Forbidden.',
                    ]);
            }
        }
    }

    public function test_unauthenticated_requests_to_user_endpoints_return_401(): void
    {
        $this->getJson('/api/users')->assertStatus(401)
            ->assertJson([
                'message' => 'Unauthenticated.',
            ]);

        $this->postJson('/api/users', [
            'name' => 'No Token',
            'email' => 'notoken@dys.com',
            'role' => 'Event Manager',
            'sector_id' => $this->eventsSector->id,
        ])->assertStatus(401);
    }

    public function test_owner_can_reset_temporary_password_that_allows_login_and_invalidates_old(): void
    {
        $response = $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->postJson("/api/users/{$this->maria->id}/reset-password");

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'name',
                    'email',
                    'role',
                    'sector_id',
                    'account_status',
                    'temporary_password',
                    'password_sent',
                ],
                'message',
            ])
            ->assertJson([
                'data' => [
                    'id' => $this->maria->id,
                    'role' => 'Event Manager',
                    'account_status' => 'Active',
                ],
                'message' => 'Temporary password reset successfully.',
            ]);

        $temporaryPassword = $response->json('data.temporary_password');
        $this->assertIsString($temporaryPassword);
        $this->assertGreaterThanOrEqual(8, strlen($temporaryPassword));
        $this->assertMatchesRegularExpression('/[A-Z]/', $temporaryPassword);
        $this->assertMatchesRegularExpression('/[a-z]/', $temporaryPassword);
        $this->assertMatchesRegularExpression('/[0-9]/', $temporaryPassword);
        $this->assertMatchesRegularExpression('/[^A-Za-z0-9]/', $temporaryPassword);

        $this->postJson('/api/login', [
            'email' => 'maria@dys.com',
            'password' => $temporaryPassword,
        ])->assertStatus(200);

        $this->postJson('/api/login', [
            'email' => 'maria@dys.com',
            'password' => 'SecurePass123',
        ])->assertStatus(401);

        $this->assertTrue(Hash::check(
            $temporaryPassword,
            User::find($this->maria->id)->password
        ));
    }

    public function test_owner_cannot_reset_own_password(): void
    {
        $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->postJson("/api/users/{$this->owner->id}/reset-password")
            ->assertStatus(403)
            ->assertJson([
                'message' => 'Forbidden.',
            ]);

        $this->assertTrue(Hash::check(
            'SecurePass123',
            User::find($this->owner->id)->password
        ));
    }

    public function test_reset_password_for_nonexistent_user_returns_404(): void
    {
        $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->postJson('/api/users/999/reset-password')
            ->assertStatus(404)
            ->assertJson([
                'message' => 'User not found.',
            ]);
    }

    public function test_creating_user_emails_the_temporary_password(): void
    {
        Mail::fake();

        $response = $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->postJson('/api/users', [
                'name' => 'Rosa Martinez',
                'email' => 'rosa@dys.com',
                'role' => 'Event Manager',
                'sector_id' => $this->eventsSector->id,
            ]);

        $response->assertStatus(201)
            ->assertJson([
                'data' => [
                    'password_sent' => true,
                ],
            ]);

        $temporaryPassword = $response->json('data.temporary_password');

        Mail::assertSent(TemporaryPasswordMail::class, function (TemporaryPasswordMail $mail) use ($temporaryPassword) {
            return $mail->hasTo('rosa@dys.com')
                && $mail->user->email === 'rosa@dys.com'
                && $mail->user->role === 'Event Manager'
                && $mail->user->sector?->name === 'DYS Events'
                && $mail->temporaryPassword === $temporaryPassword
                && $mail->envelope()->subject === 'Your DYS Financial Management System Account';
        });
    }

    public function test_creating_user_survives_mail_delivery_failure(): void
    {
        Mail::shouldReceive('to')
            ->once()
            ->andReturnSelf();
        Mail::shouldReceive('send')
            ->once()
            ->andThrow(new \RuntimeException('Connection refused'));

        $response = $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->postJson('/api/users', [
                'name' => 'Rosa Martinez',
                'email' => 'rosa@dys.com',
                'role' => 'Event Manager',
                'sector_id' => $this->eventsSector->id,
            ]);

        $response->assertStatus(201)
            ->assertJson([
                'data' => [
                    'name' => 'Rosa Martinez',
                    'password_sent' => false,
                ],
            ]);

        $this->assertNotNull($response->json('data.temporary_password'));
        $this->assertDatabaseHas('users', [
            'email' => 'rosa@dys.com',
            'account_status' => 'Active',
        ]);
    }

    public function test_retrying_creation_for_existing_email_sends_no_second_email(): void
    {
        Mail::fake();

        $payload = [
            'name' => 'Rosa Martinez',
            'email' => 'rosa@dys.com',
            'role' => 'Event Manager',
            'sector_id' => $this->eventsSector->id,
        ];

        $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->postJson('/api/users', $payload)
            ->assertStatus(201);

        $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->postJson('/api/users', $payload)
            ->assertStatus(422)
            ->assertJsonValidationErrors('email');

        // Exactly one temporary-password email was ever sent, and the
        // stored password still matches the one returned by the first
        // (successful) creation — a retry can never send a stale one.
        Mail::assertSent(TemporaryPasswordMail::class, 1);
    }

    public function test_user_service_rejects_duplicate_email_when_validation_is_bypassed(): void
    {
        Mail::fake();

        $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->postJson('/api/users', [
                'name' => 'Rosa Martinez',
                'email' => 'rosa@dys.com',
                'role' => 'Event Manager',
                'sector_id' => $this->eventsSector->id,
            ])
            ->assertStatus(201);

        try {
            app(UserService::class)->createUser([
                'name' => 'Another Rosa',
                'email' => 'rosa@dys.com',
                'role' => 'Employee/Staff',
                'sector_id' => $this->eventsSector->id,
            ]);

            $this->fail('Expected an HttpException for the duplicate email.');
        } catch (HttpException $exception) {
            $this->assertSame(422, $exception->getStatusCode());
            $this->assertSame('Email has already been taken.', $exception->getMessage());
        }

        Mail::assertSent(TemporaryPasswordMail::class, 1);
    }

    public function test_owner_can_list_all_users_with_denormalized_sector_names(): void
    {
        $response = $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->getJson('/api/users');

        $response->assertStatus(200)
            ->assertJson([
                'message' => 'Users retrieved successfully.',
            ])
            ->assertJsonStructure([
                'data' => [[
                    'id',
                    'name',
                    'email',
                    'role',
                    'sector_id',
                    'sector_name',
                    'account_status',
                    'created_at',
                ]],
                'message',
            ]);

        $data = $response->json('data');
        $this->assertCount(4, $data);
        $this->assertTrue(collect($data)->contains(fn ($user) => $user['email'] === 'owner@dys.com' && $user['role'] === 'Business Owner' && $user['sector_name'] === null));
        $this->assertTrue(collect($data)->contains(fn ($user) => $user['email'] === 'maria@dys.com' && $user['sector_name'] === 'B&DYS'));
        $this->assertTrue(collect($data)->contains(fn ($user) => $user['email'] === 'ana@dys.com' && $user['sector_name'] === 'DYS Events'));
        $this->assertTrue(collect($data)->contains(fn ($user) => $user['email'] === 'leo@dys.com' && $user['account_status'] === 'Inactive'));
    }

    public function test_owner_cannot_update_own_account(): void
    {
        $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->putJson("/api/users/{$this->owner->id}", [
                'name' => 'Hacked Name',
                'email' => 'owner@dys.com',
                'role' => 'Event Manager',
                'sector_id' => $this->eventsSector->id,
            ])->assertStatus(403)
            ->assertJson([
                'message' => 'Forbidden.',
            ]);

        $this->assertDatabaseHas('users', [
            'id' => $this->owner->id,
            'name' => 'Juan Dela Cruz',
        ]);
    }

    public function test_owner_cannot_deactivate_own_account(): void
    {
        $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->patchJson("/api/users/{$this->owner->id}/status", [
                'account_status' => 'Inactive',
            ])->assertStatus(403)
            ->assertJson([
                'message' => 'Forbidden.',
            ]);

        $this->assertDatabaseHas('users', [
            'id' => $this->owner->id,
            'account_status' => 'Active',
        ]);
    }

    public function test_show_nonexistent_user_returns_404(): void
    {
        $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->getJson('/api/users/999')
            ->assertStatus(404)
            ->assertJson([
                'message' => 'User not found.',
            ]);
    }

    public function test_updating_user_with_business_owner_role_returns_422(): void
    {
        $this->withHeader('Authorization', 'Bearer '.$this->ownerToken())
            ->putJson("/api/users/{$this->maria->id}", [
                'name' => 'Maria Santos',
                'email' => 'maria@dys.com',
                'role' => 'Business Owner',
                'sector_id' => $this->eventsSector->id,
            ])
            ->assertStatus(422)
            ->assertJson([
                'message' => 'The selected role is invalid.',
                'errors' => [
                    'role' => ['The selected role is invalid.'],
                ],
            ]);

        $this->assertDatabaseHas('users', [
            'id' => $this->maria->id,
            'role' => 'Event Manager',
        ]);
    }
}
