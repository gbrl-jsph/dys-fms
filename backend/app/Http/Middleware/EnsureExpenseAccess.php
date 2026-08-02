<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureExpenseAccess
{
    /**
     * Allows only Business Owners and Event Managers through.
     * Employees are rejected with 403 (validation-rules BR-13).
     * Event Manager sector scoping is enforced in the expense service.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $role = $request->user()?->role;

        if ($role !== 'Business Owner' && $role !== 'Event Manager') {
            abort(403, 'Forbidden.');
        }

        return $next($request);
    }
}
