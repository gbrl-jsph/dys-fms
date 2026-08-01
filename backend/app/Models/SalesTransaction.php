<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SalesTransaction extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'user_id',
        'sector_id',
        'amount',
        'description',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function sector(): BelongsTo
    {
        return $this->belongsTo(BusinessSector::class, 'sector_id');
    }
}
