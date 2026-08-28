<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Idempotent: use updateOrInsert so repeated RUN_SEEDERS=true (e.g., container restarts)
        // does not fail with duplicate email 1062 when owner already exists in production.
        DB::table('users')->updateOrInsert(
            ['email' => 'owner@dys.com'],
            [
                'name' => 'Juan Dela Cruz',
                'password' => Hash::make('SecurePass123'),
                'role' => 'Business Owner',
                'sector_id' => null,
                'account_status' => 'Active',
                'updated_at' => now(),
            ]
        );
    }
}
