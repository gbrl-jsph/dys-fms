<?php

namespace App\Http\Requests\Users;

use Illuminate\Foundation\Http\FormRequest;

class UpdateUserStatusRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'account_status' => ['required', 'string', 'in:Active,Inactive'],
        ];
    }

    public function messages(): array
    {
        return [
            'account_status.required' => 'Account status is required.',
            'account_status.in' => 'The selected account_status is invalid.',
        ];
    }
}
