<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Booking extends Model
{
  protected $fillable = ['user_id', 'flight_data', 'paid'];
    protected $casts = [
        'flight_data' => 'array',
    ];
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
