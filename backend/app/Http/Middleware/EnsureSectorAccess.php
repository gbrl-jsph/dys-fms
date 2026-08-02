<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureSectorAccess
{
    /**
     * Listing business sectors is available to every authenticated role
     * (validation-rules row 115). Switching is reserved for the Business
     * Owner only (BR-06, TC-FR008-03). Unknown roles are rejected.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $role = $request->user()?->role;

        if ($request->isMethod('post') && $role !== 'Business Owner') {
            abort(403, 'Forbidden.');
        }

        if (! in_array($role, ['Business Owner', 'Event Manager', 'Employee/Staff'], true)) {
            abort(403, 'Forbidden.');
        }

        return $next($request);
    }
}
