<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Users\StoreUserRequest;
use App\Http\Requests\Users\UpdateUserRequest;
use App\Http\Requests\Users\UpdateUserStatusRequest;
use App\Services\UserService;
use Illuminate\Http\JsonResponse;

class UserController extends Controller
{
    public function __construct(
        private readonly UserService $userService,
    ) {}

    public function index(): JsonResponse
    {
        return response()->json([
            'data' => $this->userService->listUsers(),
            'message' => 'Users retrieved successfully.',
        ]);
    }

    public function store(StoreUserRequest $request): JsonResponse
    {
        return response()->json([
            'data' => $this->userService->createUser($request->validated()),
            'message' => 'User account created successfully.',
        ], 201);
    }

    public function show(int $id): JsonResponse
    {
        return response()->json([
            'data' => $this->userService->showUser($id),
            'message' => 'User retrieved successfully.',
        ]);
    }

    public function update(UpdateUserRequest $request, int $id): JsonResponse
    {
        return response()->json([
            'data' => $this->userService->updateUser($id, $request->validated()),
            'message' => 'User updated successfully.',
        ]);
    }

    public function updateStatus(UpdateUserStatusRequest $request, int $id): JsonResponse
    {
        return response()->json([
            'data' => $this->userService->updateStatus($id, $request->validated()['account_status']),
            'message' => 'User status updated successfully.',
        ]);
    }
}
