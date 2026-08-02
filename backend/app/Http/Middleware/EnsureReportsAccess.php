<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureReportsAccess
{
    /**
     * Allows Business Owners and Event Managers through; employees are
     * rejected with 403 (validation-rules BR-14). The analytics report
     * type is reserved for the Business Owner (TC-FR007-02).
     */
    public function handle(Request $request, Closure $next): Response
    {
        $role = $request->user()?->role;

        if ($role !== 'Business Owner' && $role !== 'Event Manager') {
            abort(403, 'Forbidden.');
        }

        if ($role === 'Event Manager' && $request->query('type') === 'analytics') {
            abort(403, 'Forbidden. Analytics dashboard is available for Business Owner only.');
        }

        return $next($request);
    }
}
