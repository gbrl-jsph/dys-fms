<?php

namespace Tests\Feature\Auth;

use App\Models\User;
use App\Models\BusinessSector;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AuthenticationTest extends TestCase
{
    use RefreshDatabase;

    private array $validCredentials = [
        'email' => 'owner@dys.com',
        'password' => 'SecurePass123',
    ];

    protected function setUp(): void
    {
        parent::setUp();

        $sector = BusinessSector::create([
            'name' => 'DYS Events',
            'description' => 'Event coordination and styling main branch',
        ]);

        User::create([
            'name' => 'Juan Dela Cruz',
            'email' => 'owner@dys.com',
            'password' => Hash::make('SecurePass123'),
            'role' => 'Business Owner',
            'sector_id' => null,
            'account_status' => 'Active',
        ]);

        User::create([
            'name' => 'Maria Santos',
            'email' => 'inactive@dys.com',
            'password' => Hash::make('SecurePass123'),
            'role' => 'Event Manager',
            'sector_id' => $sector->id,
            'account_status' => 'Inactive',
        ]);
    }

    public function test_successful_login_returns_200_with_user_token_and_default_sector(): void
    {
        $response = $this->postJson('/api/login', $this->validCredentials);

        $response->assertStatus(200)
            ->assertJsonStructure([
                'data' => [
                    'user' => [
                        'id',
                        'name',
                        'email',
                        'role',
                        'sector_id',
                        'account_status',
                    ],
                    'token',
                    'default_sector' => [
                        'id',
                        'name',
                    ],
                ],
                'message',
            ])
            ->assertJson([
                'data' => [
                    'user' => [
                        'id' => 1,
                        'name' => 'Juan Dela Cruz',
                        'email' => 'owner@dys.com',
                        'role' => 'Business Owner',
                        'sector_id' => null,
                        'account_status' => 'Active',
                    ],
                    'default_sector' => [
                        'id' => 1,
                        'name' => 'DYS Events',
                    ],
                ],
                'message' => 'Login successful.',
            ]);

        $this->assertIsString($response->json('data.token'));
        $this->assertStringContainsString('|', $response->json('data.token'));
    }

    public function test_login_fails_with_incorrect_password(): void
    {
        $response = $this->postJson('/api/login', [
            'email' => 'owner@dys.com',
            'password' => 'WrongPassword123',
        ]);

        $response->assertStatus(401)
            ->assertJson([
                'message' => 'Invalid username or password.',
            ]);
    }

    public function test_login_fails_with_nonexistent_email(): void
    {
        $response = $this->postJson('/api/login', [
            'email' => 'nonexistent@dys.com',
            'password' => 'SecurePass123',
        ]);

        $response->assertStatus(401)
            ->assertJson([
                'message' => 'Invalid username or password.',
            ]);
    }

    public function test_login_fails_when_account_is_inactive(): void
    {
        $response = $this->postJson('/api/login', [
            'email' => 'inactive@dys.com',
            'password' => 'SecurePass123',
        ]);

        $response->assertStatus(401)
            ->assertJson([
                'message' => 'Invalid username or password.',
            ]);
    }

    public function test_login_returns_422_when_email_is_missing(): void
    {
        $response = $this->postJson('/api/login', [
            'password' => 'SecurePass123',
        ]);

        $response->assertStatus(422)
            ->assertJson([
                'message' => 'The email field is required.',
            ]);
    }

    public function test_login_returns_422_when_email_is_invalid_format(): void
    {
        $response = $this->postJson('/api/login', [
            'email' => 'not-an-email',
            'password' => 'SecurePass123',
        ]);

        $response->assertStatus(422)
            ->assertJson([
                'message' => 'The email must be a valid email address.',
            ]);
    }

    public function test_login_returns_422_when_password_is_missing(): void
    {
        $response = $this->postJson('/api/login', [
            'email' => 'owner@dys.com',
        ]);

        $response->assertStatus(422)
            ->assertJson([
                'message' => 'The password field is required.',
            ]);
    }

    public function test_logout_with_valid_token_returns_200(): void
    {
        $loginResponse = $this->postJson('/api/login', $this->validCredentials);
        $token = $loginResponse->json('data.token');

        $response = $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson('/api/logout');

        $response->assertStatus(200)
            ->assertJson([
                'message' => 'Logged out successfully.',
            ]);
    }

    public function test_logout_without_token_returns_401(): void
    {
        $response = $this->postJson('/api/logout');

        $response->assertStatus(401)
            ->assertJson([
                'message' => 'Unauthenticated.',
            ]);
    }

    public function test_token_is_revoked_after_logout(): void
    {
        $loginResponse = $this->postJson('/api/login', $this->validCredentials);
        $token = $loginResponse->json('data.token');
        $tokenId = explode('|', $token)[0];

        $this->assertDatabaseHas('personal_access_tokens', ['id' => $tokenId]);

        $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson('/api/logout');

        $this->assertDatabaseMissing('personal_access_tokens', ['id' => $tokenId]);
    }
}
