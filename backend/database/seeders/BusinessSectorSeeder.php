<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class BusinessSectorSeeder extends Seeder
{
    public function run(): void
    {
        // Preserve referenced sectors and financial records on every deploy.
        foreach ([
            [
                'id' => 1,
                'name' => 'DYS Events',
                'description' => 'Event coordination and styling main branch',
            ],
            [
                'id' => 2,
                'name' => 'B&DYS',
                'description' => 'Souvenirs',
            ],
            [
                'id' => 3,
                'name' => 'Flavors by DYS',
                'description' => 'Grazing tables and celebration drinks',
            ],
            [
                'id' => 4,
                'name' => 'SnapDYS Memories',
                'description' => 'Video guestbook',
            ],
        ] as $sector) {
            DB::table('business_sectors')->updateOrInsert(
                ['id' => $sector['id']],
                $sector,
            );
        }
    }
}
