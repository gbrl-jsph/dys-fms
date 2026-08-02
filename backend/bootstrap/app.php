<?php

use App\Http\Middleware\EnsureBusinessOwner;
use App\Http\Middleware\EnsureExpenseAccess;
use App\Http\Middleware\EnsurePayrollAccess;
use App\Http\Middleware\EnsureReportsAccess;
use App\Http\Middleware\EnsureSalesAccess;
use App\Http\Middleware\EnsureSectorAccess;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        api: __DIR__.'/../routes/api.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        $middleware->alias([
            'owner' => EnsureBusinessOwner::class,
            'sales' => EnsureSalesAccess::class,
            'expense' => EnsureExpenseAccess::class,
            'payroll' => EnsurePayrollAccess::class,
            'reports' => EnsureReportsAccess::class,
            'sector' => EnsureSectorAccess::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        //
    })->create();
