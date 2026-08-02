<?php

namespace App\Mail;

use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

/**
 * Emails the one-time temporary password when an account is created
 * (or reset). The password is delivered only through this channel and
 * is never stored in plaintext anywhere in the system.
 */
class TemporaryPasswordMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        public readonly User $user,
        public readonly string $temporaryPassword,
    ) {}

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Your DYS FMS account temporary password',
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.temporary_password',
            with: [
                'userName' => $this->user->name,
                'temporaryPassword' => $this->temporaryPassword,
            ],
        );
    }
}
