<?php

namespace App\Http\Requests\Payroll;

use App\Models\User;
use Illuminate\Foundation\Http\FormRequest;

class StorePayrollRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Follows the Payroll validation rules matrix (rows 87-91).
     * computed_salary and sector_id are never client-supplied; they are
     * derived server-side in the payroll service.
     */
    public function rules(): array
    {
        return [
            'user_id' => ['required', 'integer', 'exists:users,id'],
            'hours_worked' => ['required', 'numeric', 'gt:0', 'max:99999999.99'],
            'hourly_rate' => ['required', 'numeric', 'gt:0', 'max:99999999.99'],
            'pay_period' => ['required', 'date_format:Y-m-d'],
        ];
    }

    /**
     * Payroll cannot target the Business Owner themselves (TC-FR006-03,
     * E34). Runs after the base rules so the user is guaranteed to exist.
     */
    public function after(): array
    {
        return [
            function ($validator) {
                $employee = User::find($this->input('user_id'));

                if ($employee && $employee->role === 'Business Owner') {
                    $validator->errors()->add('user_id', 'Payroll cannot be calculated for the Business Owner.');
                }
            },
        ];
    }

    public function messages(): array
    {
        return [
            'user_id.required' => 'Employee is required.',
            'user_id.integer' => 'The selected user_id is invalid.',
            'user_id.exists' => 'The selected user_id is invalid.',
            'hours_worked.required' => 'Hours worked is required.',
            'hours_worked.numeric' => 'Hours worked must be a number.',
            'hours_worked.gt' => 'Hours worked must be a positive number.',
            'hours_worked.max' => 'Hours worked must not exceed 99999999.99.',
            'hourly_rate.required' => 'Hourly rate is required.',
            'hourly_rate.numeric' => 'Hourly rate must be a number.',
            'hourly_rate.gt' => 'Hourly rate must be a positive number.',
            'hourly_rate.max' => 'Hourly rate must not exceed 99999999.99.',
            'pay_period.required' => 'Pay period is required.',
            'pay_period.date_format' => 'Pay period must be a valid date.',
        ];
    }
}
