<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\ChangePasswordRequest;
use App\Http\Requests\Auth\ForgotPasswordRequest;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\ResetPasswordRequest;
use App\Http\Requests\Auth\UpdateProfileRequest;
use App\Services\AuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;

class AuthController extends Controller
{
    public function __construct(
        private readonly AuthService $authService,
    ) {}

    public function login(LoginRequest $request): JsonResponse
    {
        $result = $this->authService->login($request->validated());

        return response()->json([
            'data' => $result,
            'message' => 'Login successful.',
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $this->authService->logout($request->user());

        return response()->json([
            'message' => 'Logged out successfully.',
        ]);
    }

    public function profile(Request $request): JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'sector_id' => $user->sector_id,
                'sector_name' => $user->sector?->name,
                'account_status' => $user->account_status,
                'created_at' => $user->created_at?->toIso8601String(),
                'updated_at' => $user->updated_at?->toIso8601String(),
            ],
            'message' => 'Profile retrieved successfully.',
        ]);
    }

    public function updateProfile(UpdateProfileRequest $request): JsonResponse
    {
        $user = $request->user();
        $validated = $request->validated();

        $user->update(['name' => $validated['name']]);

        \App\Models\AuditLog::create([
            'user_id' => $user->id,
            'action' => 'profile_updated',
            'auditable_type' => \App\Models\User::class,
            'auditable_id' => $user->id,
            'new_values' => ['name' => $validated['name']],
            'ip_address' => $request->ip(),
        ]);

        return response()->json([
            'data' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'sector_id' => $user->sector_id,
                'account_status' => $user->account_status,
            ],
            'message' => 'Profile updated successfully.',
        ]);
    }

    public function changePassword(ChangePasswordRequest $request): JsonResponse
    {
        $user = $request->user();
        $validated = $request->validated();

        if (!Hash::check($validated['current_password'], $user->password)) {
            return response()->json([
                'message' => 'Current password is incorrect.',
                'errors' => ['current_password' => ['Current password is incorrect.']],
            ], 422);
        }

        if (Hash::check($validated['new_password'], $user->password)) {
            return response()->json([
                'message' => 'New password must be different from current password.',
                'errors' => ['new_password' => ['New password must be different from current password.']],
            ], 422);
        }

        $user->update(['password' => Hash::make($validated['new_password'])]);
        $user->tokens()->delete();

        \App\Models\AuditLog::create([
            'user_id' => $user->id,
            'action' => 'password_changed',
            'auditable_type' => \App\Models\User::class,
            'auditable_id' => $user->id,
            'ip_address' => $request->ip(),
        ]);

        return response()->json([
            'message' => 'Password changed successfully. Please login again.',
        ]);
    }

    public function forgotPassword(ForgotPasswordRequest $request): JsonResponse
    {
        $validated = $request->validated();

        try {
            Password::sendResetLink(['email' => $validated['email']]);
        } catch (\Throwable $e) {
            \Illuminate\Support\Facades\Log::warning('Password reset email failed: '.$e->getMessage());
            // Fail-soft: still return generic success to prevent enumeration
            // and to allow QA without working SMTP.
        }

        // Do not expose whether email exists — always return success message
        // to prevent account enumeration. Laravel's Password::sendResetLink
        // already handles this, but we ensure generic response.
        return response()->json([
            'message' => 'If an account exists with that email, a password reset link has been sent.',
        ]);
    }

    public function resetPassword(ResetPasswordRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $status = Password::reset(
            [
                'email' => $validated['email'],
                'password' => $validated['password'],
                'password_confirmation' => $validated['password_confirmation'],
                'token' => $validated['token'],
            ],
            function ($user, $password) {
                $user->forceFill(['password' => Hash::make($password)])->save();
                $user->tokens()->delete();

                \App\Models\AuditLog::create([
                    'user_id' => $user->id,
                    'action' => 'password_reset',
                    'auditable_type' => \App\Models\User::class,
                    'auditable_id' => $user->id,
                    'ip_address' => request()->ip(),
                ]);
            }
        );

        if ($status === Password::PASSWORD_RESET) {
            return response()->json(['message' => 'Password has been reset successfully.']);
        }

        return response()->json([
            'message' => 'Invalid or expired reset token.',
            'errors' => ['email' => ['Invalid or expired reset token.']],
        ], 422);
    }
}
