<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class BusinessSectorSeeder extends Seeder
{
    public function run(): void
    {
        // Ensure deterministic IDs 1-4 for the four approved sectors.
        // Truncate first so repeated seeds (e.g., phone QA) do not create
        // stale IDs like 51-54 that would break Flutter's BusinessSectorsConfig
        // and any persisted sector_id (see: Selector ID is invalid).
        DB::statement('SET FOREIGN_KEY_CHECKS=0');
        DB::table('business_sectors')->truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1');

        DB::table('business_sectors')->insert([
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
        ]);
    }
}
