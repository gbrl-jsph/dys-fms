<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Sectors\SwitchSectorRequest;
use App\Services\BusinessSectorService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BusinessSectorController extends Controller
{
    public function __construct(
        private readonly BusinessSectorService $businessSectorService,
    ) {}

    public function index(Request $request): JsonResponse
    {
        return response()->json([
            'data' => $this->businessSectorService->listSectors(),
            'message' => 'Business sectors retrieved successfully.',
        ]);
    }

    public function switchSector(SwitchSectorRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $data = $this->businessSectorService->switchSector(
            (int) $validated['sector_id'],
            isset($validated['previous_sector_id']) ? (int) $validated['previous_sector_id'] : null,
        );

        return response()->json([
            'data' => $data,
            'message' => 'Sector switched successfully.',
        ]);
    }
}
