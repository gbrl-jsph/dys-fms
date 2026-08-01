<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('users')->insert([
            'name' => 'Juan Dela Cruz',
            'email' => 'owner@dys.com',
            'password' => Hash::make('SecurePass123'),
            'role' => 'Business Owner',
            'sector_id' => null,
            'account_status' => 'Active',
        ]);
    }
}
