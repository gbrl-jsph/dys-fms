<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureBusinessOwner
{
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->user()?->role !== 'Business Owner') {
            abort(403, 'Forbidden.');
        }

        return $next($request);
    }
}
