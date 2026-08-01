<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

class PayrollRecord extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'user_id',
        'sector_id',
        'hours_worked',
        'hourly_rate',
        'computed_salary',
        'pay_period',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function sector(): BelongsTo
    {
        return $this->belongsTo(BusinessSector::class, 'sector_id');
    }

    public function expense(): HasOne
    {
        return $this->hasOne(Expense::class, 'payroll_record_id');
    }
}
