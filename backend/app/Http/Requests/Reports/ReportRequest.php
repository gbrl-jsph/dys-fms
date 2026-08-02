<?php

namespace App\Http\Requests\Reports;

use Illuminate\Foundation\Http\FormRequest;

class ReportRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Follows the Reports validation rules matrix (rows 103-107).
     * sector_id is validated for the Business Owner only; for the Event
     * Manager it is overridden with the assigned sector in the service.
     */
    public function rules(): array
    {
        $rules = [
            'type' => ['sometimes', 'string', 'in:summary,sales,expenses,analytics'],
            'date_from' => ['sometimes', 'date_format:Y-m-d'],
            'date_to' => ['sometimes', 'date_format:Y-m-d'],
        ];

        if ($this->user()?->role === 'Business Owner') {
            $rules['sector_id'] = ['sometimes', 'integer', 'exists:business_sectors,id'];
        }

        return $rules;
    }

    public function messages(): array
    {
        return [
            'type.in' => 'The selected type is invalid.',
            'sector_id.integer' => 'The selected sector_id is invalid.',
            'sector_id.exists' => 'The selected sector_id is invalid.',
            'date_from.date_format' => 'Invalid start date.',
            'date_to.date_format' => 'Invalid end date.',
        ];
    }
}
