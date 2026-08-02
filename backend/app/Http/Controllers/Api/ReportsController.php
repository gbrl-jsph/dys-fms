<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Reports\ReportRequest;
use App\Models\User;
use App\Services\ReportsService;
use Illuminate\Http\JsonResponse;

class ReportsController extends Controller
{
    public function __construct(
        private readonly ReportsService $reportsService,
    ) {}

    public function show(ReportRequest $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        $validated = $request->validated();

        $result = $this->reportsService->generateReport($user, [
            'type' => $validated['type'] ?? 'summary',
            'sector_id' => $user->role === 'Business Owner' && isset($validated['sector_id'])
                ? (int) $validated['sector_id']
                : null,
            'date_from' => $validated['date_from'] ?? null,
            'date_to' => $validated['date_to'] ?? null,
        ]);

        return response()->json([
            'data' => $result['data'],
            'message' => $result['message'],
        ]);
    }
}
