<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureExpenseAccess
{
    /**
     * Allows expense logging for Business Owners, Event Managers, and
     * Employee/Event Staff. Scope and ownership checks live in the service.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $role = $request->user()?->role;

        if (! in_array($role, ['Business Owner', 'Event Manager', 'Employee/Staff'], true)) {
            abort(403, 'Forbidden.');
        }

        return $next($request);
    }
}
