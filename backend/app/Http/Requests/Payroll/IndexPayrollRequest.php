<?php

namespace App\Http\Requests\Payroll;

use Illuminate\Foundation\Http\FormRequest;

class IndexPayrollRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * sector_id and user_id are advisory filters, overridden by role
     * scoping in the service (api-specification: "filtering parameters
     * are advisory"). Only pagination parameters are constrained.
     */
    public function rules(): array
    {
        return [
            'per_page' => ['sometimes', 'integer', 'min:1', 'max:100'],
            'page' => ['sometimes', 'integer', 'min:1'],
        ];
    }

    public function messages(): array
    {
        return [
            'per_page.min' => 'The per_page parameter must be at least 1.',
            'per_page.max' => 'The per_page parameter must not exceed 100.',
        ];
    }
}
