<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class BusinessSectorSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('business_sectors')->insert([
            [
                'name' => 'DYS Events',
                'description' => 'Event coordination and styling main branch',
            ],
            [
                'name' => 'B&DYS',
                'description' => 'Souvenirs',
            ],
            [
                'name' => 'Flavors by DYS',
                'description' => 'Grazing tables and celebration drinks',
            ],
            [
                'name' => 'SnapDYS Memories',
                'description' => 'Video guestbook',
            ],
        ]);
    }
}
