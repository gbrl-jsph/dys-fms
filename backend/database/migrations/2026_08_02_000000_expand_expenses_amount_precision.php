<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * The payroll salary limit is 99999999.99 (computed_salary is
     * decimal(10,2)); the automatically recorded payroll expense must
     * be able to hold that value, so expenses.amount is widened from
     * the default decimal(8,2).
     */
    public function up(): void
    {
        Schema::table('expenses', function (Blueprint $table) {
            $table->decimal('amount', 10, 2)->change();
        });
    }

    public function down(): void
    {
        Schema::table('expenses', function (Blueprint $table) {
            $table->decimal('amount', 8, 2)->change();
        });
    }
};
