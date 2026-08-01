<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('payroll_records', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')
                ->constrained('users')
                ->cascadeOnUpdate()
                ->restrictOnDelete();
            $table->foreignId('sector_id')
                ->constrained('business_sectors')
                ->cascadeOnUpdate()
                ->restrictOnDelete();
            $table->decimal('hours_worked', 10, 2);
            $table->decimal('hourly_rate', 10, 2);
            $table->decimal('computed_salary', 10, 2);
            $table->date('pay_period');
            $table->timestamp('calculated_at')->useCurrent();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('payroll_records');
    }
};
