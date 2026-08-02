<?php

namespace App\Services;

use App\Models\BusinessSector;

class BusinessSectorService
{
    /**
     * Lists all business sectors ordered by id. Available to every
     * authenticated role (validation-rules row 115, TC-FR008-04).
     *
     * @return array<int, array{id: int, name: string, description: ?string}>
     */
    public function listSectors(): array
    {
        return BusinessSector::orderBy('id')
            ->get()
            ->map(fn (BusinessSector $sector) => [
                'id' => $sector->id,
                'name' => $sector->name,
                'description' => $sector->description,
            ])
            ->values()
            ->all();
    }

    /**
     * Acknowledges a sector switch without modifying any data — the
     * switch is a client-side context change (api-specification: "No
     * data is modified on the server"). previous_sector_id is supplied
     * by the client and echoed back for synchronization; it is null
     * when the client does not provide its current context.
     *
     * @return array{previous_sector: array{id: int, name: string}|null,
     *     current_sector: array{id: int, name: string}}
     */
    public function switchSector(int $sectorId, ?int $previousSectorId): array
    {
        $currentSector = BusinessSector::findOrFail($sectorId);

        $previousSector = $previousSectorId !== null
            ? BusinessSector::find($previousSectorId)
            : null;

        return [
            'previous_sector' => $previousSector
                ? ['id' => $previousSector->id, 'name' => $previousSector->name]
                : null,
            'current_sector' => [
                'id' => $currentSector->id,
                'name' => $currentSector->name,
            ],
        ];
    }
}
