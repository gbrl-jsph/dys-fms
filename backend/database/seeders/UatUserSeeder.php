<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class UatUserSeeder extends Seeder
{
    public function run(): void
    {
        if (! filter_var(env('SEED_UAT_USERS', false), FILTER_VALIDATE_BOOLEAN)) {
            return;
        }

        $passwords = [
            'UAT_OWNER_PASSWORD',
            'UAT_MANAGER_PASSWORD',
            'UAT_BOOKKEEPER_PASSWORD',
            'UAT_EMPLOYEE_PASSWORD',
        ];

        foreach ($passwords as $variable) {
            if (blank(env($variable))) {
                throw new \RuntimeException("{$variable} must be set before seeding UAT users.");
            }
        }

        $firstSectorId = DB::table('business_sectors')->orderBy('id')->value('id');

        if ($firstSectorId === null) {
            throw new \RuntimeException('At least one business sector must exist before seeding UAT users.');
        }

        foreach ([
            [
                'name' => 'UAT Business Owner',
                'email' => 'uat-owner@dys.com',
                'password' => env('UAT_OWNER_PASSWORD'),
                'role' => User::BUSINESS_OWNER,
                'sector_id' => null,
            ],
            [
                'name' => 'UAT Event Manager',
                'email' => 'uat-manager@dys.com',
                'password' => env('UAT_MANAGER_PASSWORD'),
                'role' => User::EVENT_MANAGER,
                'sector_id' => $firstSectorId,
            ],
            [
                'name' => 'UAT Bookkeeper',
                'email' => 'uat-bookkeeper@dys.com',
                'password' => env('UAT_BOOKKEEPER_PASSWORD'),
                'role' => User::BOOKKEEPER,
                'sector_id' => null,
            ],
            [
                'name' => 'UAT Employee',
                'email' => 'uat-employee@dys.com',
                'password' => env('UAT_EMPLOYEE_PASSWORD'),
                'role' => User::EMPLOYEE_STAFF,
                'sector_id' => $firstSectorId,
            ],
        ] as $user) {
            if (DB::table('users')->where('email', $user['email'])->exists()) {
                continue;
            }

            DB::table('users')->insertOrIgnore([
                'name' => $user['name'],
                'email' => $user['email'],
                'password' => Hash::make($user['password']),
                'role' => $user['role'],
                'sector_id' => $user['sector_id'],
                'account_status' => 'Active',
                'created_at' => now(),
                'updated_at' => now(),
            ]);
        }
    }
}
