<?php

namespace App\Http\Requests\Sectors;

use Illuminate\Foundation\Http\FormRequest;

class SwitchSectorRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Follows the Business Sector Switching validation rules matrix
     * (row 113). previous_sector_id is the client's current sector
     * context, sent for the stateless switch acknowledgement
     * (api-specification: "the sector context is maintained client-side").
     */
    public function rules(): array
    {
        return [
            'sector_id' => ['required', 'integer', 'exists:business_sectors,id'],
            'previous_sector_id' => ['sometimes', 'integer', 'exists:business_sectors,id'],
        ];
    }

    public function messages(): array
    {
        return [
            'sector_id.required' => 'Sector is required.',
            'sector_id.integer' => 'The selected sector_id is invalid.',
            'sector_id.exists' => 'The selected sector_id is invalid.',
            'previous_sector_id.integer' => 'The selected previous_sector_id is invalid.',
            'previous_sector_id.exists' => 'The selected previous_sector_id is invalid.',
        ];
    }
}
