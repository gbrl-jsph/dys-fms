<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureReportsAccess
{
    /**
     * All final-design roles can read reports and analytics. Sector scope is
     * enforced in the reports service.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $role = $request->user()?->role;

        if (! in_array($role, ['Business Owner', 'Event Manager', 'Bookkeeper', 'Employee/Staff'], true)) {
            abort(403, 'Forbidden.');
        }

        return $next($request);
    }
}
