<?php

namespace App\Services;

use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Hash;

class UserService
{
    public function listUsers(): Collection
    {
        return User::with('sector')
            ->orderBy('id')
            ->get()
            ->map(fn (User $user) => $this->format($user));
    }

    public function showUser(int $id): array
    {
        $user = User::with('sector')->find($id);

        if (!$user) {
            abort(404, 'User not found.');
        }

        return $this->format($user);
    }

    public function createUser(array $data): array
    {
        $temporaryPassword = $this->generateTemporaryPassword();

        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => Hash::make($temporaryPassword),
            'role' => $data['role'],
            'sector_id' => $data['sector_id'],
            'account_status' => 'Active',
        ]);

        $user->refresh();

        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'sector_id' => $user->sector_id,
            'account_status' => $user->account_status,
            'temporary_password' => $temporaryPassword,
            'created_at' => Carbon::parse($user->created_at)->toIso8601String(),
        ];
    }

    public function updateUser(int $id, array $data): array
    {
        $user = User::find($id);

        if (!$user) {
            abort(404, 'User not found.');
        }

        if ($user->role === 'Business Owner') {
            abort(403, 'Forbidden.');
        }

        // Defense in depth: the Business Owner role must never be assigned
        // through this endpoint (BR-33), even if validation is bypassed.
        if ($data['role'] === 'Business Owner') {
            abort(422, 'The selected role is invalid.');
        }

        $user->update([
            'name' => $data['name'],
            'email' => $data['email'],
            'role' => $data['role'],
            'sector_id' => $data['sector_id'],
        ]);

        return $this->format($user) + ['updated_at' => $user->updated_at];
    }

    public function updateStatus(int $id, string $status): array
    {
        $user = User::find($id);

        if (!$user) {
            abort(404, 'User not found.');
        }

        if ($user->role === 'Business Owner') {
            abort(403, 'Forbidden.');
        }

        $user->update(['account_status' => $status]);

        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'sector_id' => $user->sector_id,
            'account_status' => $user->account_status,
            'updated_at' => $user->updated_at,
        ];
    }

    private function format(User $user): array
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'sector_id' => $user->sector_id,
            'sector_name' => $user->sector?->name,
            'account_status' => $user->account_status,
            'created_at' => Carbon::parse($user->created_at)->toIso8601String(),
        ];
    }

    /**
     * Generates an 8-character temporary password guaranteed to contain
     * at least one uppercase, one lowercase, one digit, and one special
     * character (minimum complexity per Phase 2 requirements).
     */
    private function generateTemporaryPassword(): string
    {
        $sets = [
            'ABCDEFGHJKLMNPQRSTUVWXYZ',
            'abcdefghijkmnpqrstuvwxyz',
            '23456789',
            '!@#$%*',
        ];

        $password = '';

        foreach ($sets as $set) {
            $password .= $set[random_int(0, strlen($set) - 1)];
        }

        $all = implode('', $sets);

        for ($i = 0; $i < 4; $i++) {
            $password .= $all[random_int(0, strlen($all) - 1)];
        }

        return str_shuffle($password);
    }
}
