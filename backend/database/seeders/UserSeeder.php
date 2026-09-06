<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        $password = env('OWNER_PASSWORD');

        if (empty($password)) {
            throw new \RuntimeException('OWNER_PASSWORD must be set before seeding the initial Business Owner.');
        }

        // Create once only: production seeding must never replace an owner's password.
        DB::table('users')->insertOrIgnore(
            [
                'email' => 'owner@dys.com',
                'name' => 'Juan Dela Cruz',
                'password' => Hash::make($password),
                'role' => 'Business Owner',
                'sector_id' => null,
                'account_status' => 'Active',
                'created_at' => now(),
                'updated_at' => now(),
            ]
        );
    }
}
