<?php

namespace Tests\Feature\Configuration;

use Tests\TestCase;

class DatabaseTlsConfigurationTest extends TestCase
{
    private string|false $originalCa;

    protected function setUp(): void
    {
        parent::setUp();

        $this->originalCa = getenv('MYSQL_ATTR_SSL_CA');
    }

    protected function tearDown(): void
    {
        $this->setCa($this->originalCa === false ? null : $this->originalCa);

        parent::tearDown();
    }

    public function test_mysql_tls_options_are_unchanged_without_a_ca(): void
    {
        $this->setCa(null);

        $database = require config_path('database.php');

        $this->assertSame([], $database['connections']['mysql']['options']);
    }

    public function test_mysql_ca_enables_verified_server_certificates(): void
    {
        $this->setCa('/run/secrets/aiven-ca.pem');

        $database = require config_path('database.php');
        $options = $database['connections']['mysql']['options'];

        $this->assertSame('/run/secrets/aiven-ca.pem', $options[\PDO::MYSQL_ATTR_SSL_CA]);
        $this->assertTrue($options[\PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT]);
    }

    private function setCa(?string $value): void
    {
        if ($value === null) {
            putenv('MYSQL_ATTR_SSL_CA');
            unset($_ENV['MYSQL_ATTR_SSL_CA'], $_SERVER['MYSQL_ATTR_SSL_CA']);

            return;
        }

        putenv("MYSQL_ATTR_SSL_CA={$value}");
        $_ENV['MYSQL_ATTR_SSL_CA'] = $value;
        $_SERVER['MYSQL_ATTR_SSL_CA'] = $value;
    }
}
