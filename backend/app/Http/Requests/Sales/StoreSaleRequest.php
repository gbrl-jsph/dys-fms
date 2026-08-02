<?php

namespace App\Http\Requests\Sales;

use Illuminate\Foundation\Http\FormRequest;

class StoreSaleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Amount and description follow the Sales validation rules matrix.
     * sector_id is required for the Business Owner only; for the Event
     * Manager it is ignored/overridden with the assigned sector (TC-FR004-02).
     */
    public function rules(): array
    {
        $rules = [
            'amount' => ['required', 'numeric', 'gt:0', 'max:999999.99'],
            'description' => ['nullable', 'string'],
        ];

        if ($this->user()?->role === 'Business Owner') {
            $rules['sector_id'] = ['required', 'integer', 'exists:business_sectors,id'];
        }

        return $rules;
    }

    public function messages(): array
    {
        return [
            'amount.required' => 'Amount is required.',
            'amount.numeric' => 'Amount must be a number.',
            'amount.gt' => 'Amount must be a positive number.',
            'amount.max' => 'Amount must not exceed 999999.99.',
            'description.string' => 'Description must be a string.',
            'sector_id.required' => 'Sector is required.',
            'sector_id.integer' => 'The selected sector_id is invalid.',
            'sector_id.exists' => 'The selected sector_id is invalid.',
        ];
    }
}
