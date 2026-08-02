<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureSalesAccess
{
    /**
     * Allows only Business Owners and Event Managers through.
     * Employees are rejected with 403 (validation-rules BR-12, BR-13).
     * Event Manager sector scoping is enforced in the sales service.
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
