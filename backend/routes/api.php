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
Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
Route::post('/reset-password', [AuthController::class, 'resetPassword']);

// Temporary production diagnostic — requires X-Diagnostic-Key: DYS_DIAGNOSTIC_KEY
// No auth:sanctum, no token creation, read-only, safe metadata only.
// NEVER returns token content, token hash, passwords, APP_KEY, DB credentials, or secrets.
Route::get('/_diagnostics/auth', function (\Illuminate\Http\Request $request) {
    $expected = env('DYS_DIAGNOSTIC_KEY');
    if (!$expected || $request->header('X-Diagnostic-Key') !== $expected) {
        return response()->json(['message' => 'Not Found'], 404);
    }

    // --- Safe Authorization header metadata (no secrets) ---
    $hasAuthHeader = $request->hasHeader('Authorization');
    $authScheme = 'none';
    if ($hasAuthHeader) {
        $auth = $request->header('Authorization', '');
        if (str_starts_with($auth, 'Bearer ')) {
            $authScheme = 'Bearer';
        } elseif (str_starts_with($auth, 'Basic ')) {
            $authScheme = 'Basic';
        } else {
            $authScheme = 'other';
        }
    }

    $bearerToken = $request->bearerToken();
    $bearerTokenDetected = $bearerToken !== null;
    $bearerTokenLength = $bearerTokenDetected ? strlen($bearerToken) : 0;
    // Sanctum plainTextToken format: "{id}|{token}|{hash}" — contains two pipes
    $bearerTokenHasPipe = $bearerTokenDetected && str_contains($bearerToken, '|');
    // Token ID portion (first segment before pipe) should be numeric
    $bearerTokenIdNumeric = false;
    if ($bearerTokenHasPipe) {
        $segments = explode('|', $bearerToken);
        $bearerTokenIdNumeric = isset($segments[0]) && ctype_digit($segments[0]);
    }

    // --- Raw PHP server variables (booleans only) ---
    $phpServerVars = [
        'has_HTTP_AUTHORIZATION'       => isset($_SERVER['HTTP_AUTHORIZATION']),
        'has_REDIRECT_HTTP_AUTHORIZATION' => isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION']),
        'request_bearer_token'         => $request->bearerToken() !== null,
    ];

    // --- Safe database metadata (counts only, no PII) ---
    $canQueryPats = false;
    try {
        \Illuminate\Support\Facades\DB::table('personal_access_tokens')->limit(1)->get();
        $canQueryPats = true;
    } catch (\Throwable $e) {
        $canQueryPats = false;
    }

    $data = [
        // Authorization header analysis
        'has_authorization_header'  => $hasAuthHeader,
        'authorization_scheme'      => $authScheme,
        'bearer_token_detected'     => $bearerTokenDetected,
        'bearer_token_length'       => $bearerTokenLength,
        'bearer_token_has_pipe'     => $bearerTokenHasPipe,
        'bearer_token_id_numeric'   => $bearerTokenIdNumeric,

        // PHP server variable check (booleans only)
        'php_server'                => $phpServerVars,

        // DB health (counts only)
        'db'                        => \Illuminate\Support\Facades\DB::connection()->getDatabaseName(),
        'host'                      => \Illuminate\Support\Facades\DB::connection()->getConfig('host'),
        'default_connection'        => config('database.default'),
        'hasDbUrl'                  => filled(env('DB_URL')) ? 'DB_URL is set (overrides DB_*)' : 'DB_URL not set',
        'users_count'               => \Illuminate\Support\Facades\DB::table('users')->count(),
        'business_sectors_count'    => \Illuminate\Support\Facades\DB::table('business_sectors')->count(),
        'personal_access_tokens_count' => $canQueryPats ? \Illuminate\Support\Facades\DB::table('personal_access_tokens')->count() : 'unqueryable',
        'owner_id'                  => \Illuminate\Support\Facades\DB::table('users')->where('email', 'owner@dys.com')->value('id'),
        'can_query_pats'            => $canQueryPats,
    ];

    \Illuminate\Support\Facades\Log::info('diag auth', [
        'has_auth_header' => $hasAuthHeader,
        'auth_scheme'     => $authScheme,
        'bearer_detected' => $bearerTokenDetected,
        'bearer_length'   => $bearerTokenLength,
        'php_http_auth'   => isset($_SERVER['HTTP_AUTHORIZATION']),
        'php_redirect'    => isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION']),
    ]);

    return response()->json($data);
});

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/profile', [AuthController::class, 'profile']);
    Route::put('/profile', [AuthController::class, 'updateProfile']);
    Route::post('/change-password', [AuthController::class, 'changePassword']);

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
        Route::get('/{sale}', [SalesController::class, 'show']);
        Route::put('/{sale}', [SalesController::class, 'update']);
        Route::patch('/{sale}', [SalesController::class, 'update']);
        Route::delete('/{sale}', [SalesController::class, 'destroy']);
    });

    Route::middleware('expense')->prefix('expenses')->group(function () {
        Route::get('/', [ExpensesController::class, 'index']);
        Route::post('/', [ExpensesController::class, 'store']);
        Route::get('/{expense}', [ExpensesController::class, 'show']);
        Route::put('/{expense}', [ExpensesController::class, 'update']);
        Route::patch('/{expense}', [ExpensesController::class, 'update']);
        Route::delete('/{expense}', [ExpensesController::class, 'destroy']);
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
