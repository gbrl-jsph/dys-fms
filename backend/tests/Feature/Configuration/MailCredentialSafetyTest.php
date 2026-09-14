<?php

namespace Tests\Feature\Configuration;

use App\Mail\TemporaryPasswordMail;
use App\Models\User;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Psr\Log\LoggerInterface;
use Symfony\Component\Mailer\Exception\TransportException;
use Symfony\Component\Mailer\Exception\TransportExceptionInterface;
use Symfony\Component\Mailer\Transport\TransportInterface;
use Tests\TestCase;

class MailCredentialSafetyTest extends TestCase
{
    public function test_smtp_failure_never_falls_back_to_logging_temporary_credentials(): void
    {
        $smtp = $this->createMock(TransportInterface::class);
        $smtp->method('__toString')->willReturn('test-smtp');
        $smtp->expects($this->once())->method('send')
            ->willThrowException(new TransportException('Simulated SMTP outage.'));

        Mail::extend('test-smtp', fn () => $smtp);
        config(['mail.mailers.smtp.transport' => 'test-smtp']);

        $logger = $this->createMock(LoggerInterface::class);
        $logger->expects($this->never())->method('debug');
        Log::shouldReceive('channel')->with('single')->andReturn($logger);
        Log::shouldReceive('error')->andReturnNull();

        $user = new User(['name' => 'UAT-Test', 'role' => User::EVENT_MANAGER]);
        $user->setRelation('sector', null);

        $this->expectException(TransportExceptionInterface::class);

        Mail::mailer('failover')->to('uat@example.test')->send(
            new TemporaryPasswordMail($user, 'test-fixture-not-a-real-credential')
        );
    }
}
