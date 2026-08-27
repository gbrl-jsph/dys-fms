<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('sales_transactions', function (Blueprint $table) {
            $table->softDeletes();
            $table->timestamp('updated_at')->nullable()->useCurrentOnUpdate()->useCurrent();
        });

        Schema::table('expenses', function (Blueprint $table) {
            $table->softDeletes();
            $table->timestamp('updated_at')->nullable()->useCurrentOnUpdate()->useCurrent();
        });
    }

    public function down(): void
    {
        Schema::table('sales_transactions', function (Blueprint $table) {
            $table->dropSoftDeletes();
            $table->dropColumn('updated_at');
        });

        Schema::table('expenses', function (Blueprint $table) {
            $table->dropSoftDeletes();
            $table->dropColumn('updated_at');
        });
    }
};
