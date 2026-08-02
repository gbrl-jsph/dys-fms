<?php

namespace App\Http\Requests\Expenses;

use Illuminate\Foundation\Http\FormRequest;

class IndexExpenseRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * sector_id is required for the Business Owner to filter; for the Event
     * Manager it is ignored/overridden with the assigned sector (TC-FR005-05).
     */
    public function rules(): array
    {
        $rules = [
            'per_page' => ['sometimes', 'integer', 'min:1', 'max:100'],
            'page' => ['sometimes', 'integer', 'min:1'],
        ];

        if ($this->user()?->role === 'Business Owner') {
            $rules['sector_id'] = ['required', 'integer', 'exists:business_sectors,id'];
        }

        return $rules;
    }

    public function messages(): array
    {
        return [
            'sector_id.required' => 'Sector is required.',
            'sector_id.integer' => 'The selected sector_id is invalid.',
            'sector_id.exists' => 'The selected sector_id is invalid.',
            'per_page.min' => 'The per_page parameter must be at least 1.',
            'per_page.max' => 'The per_page parameter must not exceed 100.',
        ];
    }
}
