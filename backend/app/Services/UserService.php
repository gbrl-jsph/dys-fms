<?php

namespace App\Services;

use App\Mail\TemporaryPasswordMail;
use App\Models\User;
use Illuminate\Support\Carbon;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;

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

        // Fail-soft email delivery: account creation always succeeds even
        // when the mail transport is unavailable; the caller surfaces
        // `password_sent` so the owner can share the password manually.
        $passwordSent = $this->sendTemporaryPassword($user, $temporaryPassword);

        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'sector_id' => $user->sector_id,
            'account_status' => $user->account_status,
            'temporary_password' => $temporaryPassword,
            'password_sent' => $passwordSent,
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

    /**
     * Generates a fresh temporary password, hashes and saves it, and
     * returns it exactly once in the response (it is never stored in
     * plaintext). The Business Owner account cannot be reset through
     * this endpoint (BR-33/BR-44 defense in depth).
     */
    public function resetPassword(int $id): array
    {
        $user = User::find($id);

        if (!$user) {
            abort(404, 'User not found.');
        }

        if ($user->role === 'Business Owner') {
            abort(403, 'Forbidden.');
        }

        $temporaryPassword = $this->generateTemporaryPassword();

        $user->update(['password' => Hash::make($temporaryPassword)]);

        $passwordSent = $this->sendTemporaryPassword($user, $temporaryPassword);

        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'role' => $user->role,
            'sector_id' => $user->sector_id,
            'account_status' => $user->account_status,
            'temporary_password' => $temporaryPassword,
            'password_sent' => $passwordSent,
        ];
    }

    /**
     * Emails the one-time temporary password. Returns `true` when the
     * mailer accepted the message; failures are logged and swallowed so
     * account creation / reset never breaks because of mail delivery.
     */
    private function sendTemporaryPassword(User $user, string $temporaryPassword): bool
    {
        try {
            Mail::to($user->email)->send(
                new TemporaryPasswordMail($user, $temporaryPassword)
            );

            return true;
        } catch (\Throwable $exception) {
            Log::warning('Temporary password email could not be sent.', [
                'user_id' => $user->id,
                'error' => $exception->getMessage(),
            ]);

            return false;
        }
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
