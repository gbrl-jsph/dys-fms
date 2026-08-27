<?php

namespace App\Http\Requests\Sales;

use Illuminate\Foundation\Http\FormRequest;

class UpdateSaleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $rules = [
            'amount' => ['sometimes', 'required', 'numeric', 'gt:0', 'max:999999.99'],
            'description' => ['sometimes', 'nullable', 'string'],
            'recorded_at' => ['sometimes', 'date'],
        ];

        if ($this->user()?->role === 'Business Owner') {
            $rules['sector_id'] = ['sometimes', 'integer', 'exists:business_sectors,id'];
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
            'sector_id.integer' => 'The selected sector_id is invalid.',
            'sector_id.exists' => 'The selected sector_id is invalid.',
            'recorded_at.date' => 'Invalid date.',
        ];
    }
}
