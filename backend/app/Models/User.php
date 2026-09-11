<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;

    public const BUSINESS_OWNER = 'Business Owner';
    public const EVENT_MANAGER = 'Event Manager';
    public const BOOKKEEPER = 'Bookkeeper';
    public const EMPLOYEE_STAFF = 'Employee/Staff';

    public $timestamps = true;

    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'sector_id',
        'account_status',
    ];

    protected $hidden = [
        'password',
    ];

    public function sector(): BelongsTo
    {
        return $this->belongsTo(BusinessSector::class, 'sector_id');
    }

    public function salesTransactions(): HasMany
    {
        return $this->hasMany(SalesTransaction::class, 'user_id');
    }

    public function expenses(): HasMany
    {
        return $this->hasMany(Expense::class, 'user_id');
    }

    public function payrollRecords(): HasMany
    {
        return $this->hasMany(PayrollRecord::class, 'user_id');
    }

    public static function assignableRoles(): array
    {
        return [self::EVENT_MANAGER, self::BOOKKEEPER, self::EMPLOYEE_STAFF];
    }
}
