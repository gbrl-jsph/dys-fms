<?php

namespace Tests\Feature\Database;

use App\Models\User;
use Database\Seeders\BusinessSectorSeeder;
use Database\Seeders\DatabaseSeeder;
use Database\Seeders\UatUserSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class UatUserSeederTest extends TestCase
{
    use RefreshDatabase;

    private array $environment = [];

    protected function setUp(): void
    {
        parent::setUp();

        (new BusinessSectorSeeder)->run();

        foreach ([
            'SEED_UAT_USERS',
            'OWNER_PASSWORD',
            'UAT_OWNER_PASSWORD',
            'UAT_MANAGER_PASSWORD',
            'UAT_BOOKKEEPER_PASSWORD',
            'UAT_EMPLOYEE_PASSWORD',
        ] as $variable) {
            $this->environment[$variable] = getenv($variable);
        }
    }

    protected function tearDown(): void
    {
        foreach ($this->environment as $variable => $value) {
            if ($value === false) {
                putenv($variable);
                unset($_ENV[$variable], $_SERVER[$variable]);
            } else {
                $this->setEnvironment($variable, $value);
            }
        }

        parent::tearDown();
    }

    public function test_it_is_disabled_without_explicit_opt_in(): void
    {
        $this->setEnvironment('SEED_UAT_USERS', 'false');

        (new UatUserSeeder)->run();

        $this->assertDatabaseCount('users', 0);
    }

    public function test_it_creates_four_uat_users_with_required_password_secrets(): void
    {
        $this->enableUatSeeding();

        (new DatabaseSeeder)->run();

        $this->assertDatabaseHas('users', [
            'name' => 'UAT Business Owner',
            'email' => 'uat-owner@dys.com',
            'role' => User::BUSINESS_OWNER,
            'sector_id' => null,
        ]);
        $this->assertDatabaseHas('users', [
            'name' => 'UAT Event Manager',
            'email' => 'uat-manager@dys.com',
            'role' => User::EVENT_MANAGER,
            'sector_id' => 1,
        ]);
        $this->assertDatabaseHas('users', [
            'name' => 'UAT Bookkeeper',
            'email' => 'uat-bookkeeper@dys.com',
            'role' => User::BOOKKEEPER,
            'sector_id' => null,
        ]);
        $this->assertDatabaseHas('users', [
            'name' => 'UAT Employee',
            'email' => 'uat-employee@dys.com',
            'role' => User::EMPLOYEE_STAFF,
            'sector_id' => 1,
        ]);
        $this->assertTrue(Hash::check('owner-password', User::where('email', 'uat-owner@dys.com')->value('password')));
        $this->assertDatabaseHas('users', ['email' => 'owner@dys.com']);
    }

    public function test_it_does_not_overwrite_existing_uat_users(): void
    {
        $this->enableUatSeeding();
        User::create([
            'name' => 'Existing user',
            'email' => 'uat-manager@dys.com',
            'password' => Hash::make('existing-password'),
            'role' => User::EMPLOYEE_STAFF,
            'sector_id' => 1,
            'account_status' => 'Inactive',
        ]);

        (new UatUserSeeder)->run();

        $existingUser = User::where('email', 'uat-manager@dys.com')->firstOrFail();
        $this->assertSame('Existing user', $existingUser->name);
        $this->assertSame(User::EMPLOYEE_STAFF, $existingUser->role);
        $this->assertSame('Inactive', $existingUser->account_status);
        $this->assertTrue(Hash::check('existing-password', $existingUser->password));
        $this->assertDatabaseCount('users', 4);
    }

    public function test_it_requires_all_password_secrets_when_enabled(): void
    {
        $this->setEnvironment('SEED_UAT_USERS', 'true');
        foreach ([
            'UAT_OWNER_PASSWORD',
            'UAT_MANAGER_PASSWORD',
            'UAT_BOOKKEEPER_PASSWORD',
            'UAT_EMPLOYEE_PASSWORD',
        ] as $variable) {
            $this->clearEnvironment($variable);
        }

        $this->expectException(\RuntimeException::class);
        $this->expectExceptionMessage('UAT_OWNER_PASSWORD must be set before seeding UAT users.');

        (new UatUserSeeder)->run();
    }

    private function enableUatSeeding(): void
    {
        $this->setEnvironment('SEED_UAT_USERS', 'true');
        $this->setEnvironment('OWNER_PASSWORD', 'initial-owner-password');
        $this->setEnvironment('UAT_OWNER_PASSWORD', 'owner-password');
        $this->setEnvironment('UAT_MANAGER_PASSWORD', 'manager-password');
        $this->setEnvironment('UAT_BOOKKEEPER_PASSWORD', 'bookkeeper-password');
        $this->setEnvironment('UAT_EMPLOYEE_PASSWORD', 'employee-password');
    }

    private function setEnvironment(string $variable, string $value): void
    {
        putenv("{$variable}={$value}");
        $_ENV[$variable] = $value;
        $_SERVER[$variable] = $value;
    }

    private function clearEnvironment(string $variable): void
    {
        putenv($variable);
        unset($_ENV[$variable], $_SERVER[$variable]);
    }
}
