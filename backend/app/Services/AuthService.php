<?php

namespace App\Services;

use App\Models\User;
use App\Models\BusinessSector;
use Illuminate\Support\Facades\Hash;

class AuthService
{
    public function login(array $credentials): array
    {
        $user = User::where('email', $credentials['email'])->first();

        if (!$user || !Hash::check($credentials['password'], $user->password)) {
            abort(401, 'Invalid username or password.');
        }

        if ($user->account_status !== 'Active') {
            abort(401, 'Invalid username or password.');
        }

        $token = $user->createToken('auth-token')->plainTextToken;

        $defaultSector = $user->role === 'Business Owner'
            ? BusinessSector::find(1)
            : $user->sector;

        return [
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'sector_id' => $user->sector_id,
                'account_status' => $user->account_status,
            ],
            'token' => $token,
            'default_sector' => $defaultSector ? [
                'id' => $defaultSector->id,
                'name' => $defaultSector->name,
            ] : null,
        ];
    }

    public function logout(User $user): void
    {
        $user->currentAccessToken()->delete();
    }
}
