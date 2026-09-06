<?php

namespace App\Services;

use App\Models\User;
use App\Models\BusinessSector;
use Illuminate\Support\Facades\Hash;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Laravel\Sanctum\PersonalAccessToken;

class AuthService
{
    public function login(array $credentials, Request $request): array
    {
        $user = User::where('email', $credentials['email'])->first();

        if (!$user || !Hash::check($credentials['password'], $user->password)) {
            abort(401, 'Invalid username or password.');
        }

        if ($user->account_status !== 'Active') {
            abort(401, 'Invalid username or password.');
        }

        $isStateful = $request->attributes->get('sanctum') === true;
        if ($isStateful) {
            Auth::guard('web')->login($user);
            $request->session()->regenerate();
        }

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
            'default_sector' => $defaultSector ? [
                'id' => $defaultSector->id,
                'name' => $defaultSector->name,
            ] : null,
        ] + ($isStateful ? [] : ['token' => $user->createToken('auth-token')->plainTextToken]);
    }

    public function logout(Request $request): void
    {
        $token = $request->user()->currentAccessToken();
        if ($token instanceof PersonalAccessToken) {
            $token->delete();
            return;
        }

        Auth::guard('web')->logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
    }
}
