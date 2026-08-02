<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BusinessSectorController;
use App\Http\Controllers\Api\ExpensesController;
use App\Http\Controllers\Api\PayrollController;
use App\Http\Controllers\Api\ReportsController;
use App\Http\Controllers\Api\SalesController;
use App\Http\Controllers\Api\UserController;

Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);

    Route::middleware('owner')->prefix('users')->group(function () {
        Route::get('/', [UserController::class, 'index']);
        Route::post('/', [UserController::class, 'store']);
        Route::get('/{user}', [UserController::class, 'show']);
        Route::put('/{user}', [UserController::class, 'update']);
        Route::patch('/{user}/status', [UserController::class, 'updateStatus']);
        Route::post('/{user}/reset-password', [UserController::class, 'resetPassword']);
    });

    Route::middleware('sales')->prefix('sales')->group(function () {
        Route::get('/', [SalesController::class, 'index']);
        Route::post('/', [SalesController::class, 'store']);
    });

    Route::middleware('expense')->prefix('expenses')->group(function () {
        Route::get('/', [ExpensesController::class, 'index']);
        Route::post('/', [ExpensesController::class, 'store']);
    });

    Route::middleware('payroll')->prefix('payroll')->group(function () {
        Route::get('/', [PayrollController::class, 'index']);
        Route::post('/', [PayrollController::class, 'store']);
    });

    Route::middleware('reports')->prefix('reports')->group(function () {
        Route::get('/', [ReportsController::class, 'show']);
    });

    Route::middleware('sector')->prefix('business-sectors')->group(function () {
        Route::get('/', [BusinessSectorController::class, 'index']);
        Route::post('/switch', [BusinessSectorController::class, 'switchSector']);
    });
});
