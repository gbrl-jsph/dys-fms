<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('expenses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')
                ->constrained('users')
                ->cascadeOnUpdate()
                ->restrictOnDelete();
            $table->foreignId('sector_id')
                ->constrained('business_sectors')
                ->cascadeOnUpdate()
                ->restrictOnDelete();
            $table->decimal('amount');
            $table->text('description')->nullable();
            $table->timestamp('recorded_at')->useCurrent();
            $table->foreignId('payroll_record_id')
                ->nullable()
                ->constrained('payroll_records')
                ->cascadeOnUpdate()
                ->restrictOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('expenses');
    }
};
