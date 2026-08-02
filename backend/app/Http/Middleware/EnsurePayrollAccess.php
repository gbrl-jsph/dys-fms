<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsurePayrollAccess
{
    /**
     * GET is available to every authenticated role with role-based
     * filtering applied in the service. POST (calculate payroll) is
     * reserved for the Business Owner only (validation-rules BR-05,
     * BR-08, BR-10). Unknown roles are rejected with 403.
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
