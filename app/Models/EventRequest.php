<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Testing\Fluent\Concerns\Has;

class EventRequest extends Model
{

    use HasFactory;
    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $fillable = ['user_id', 'event_id', 'status'];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function event()
    {
        return $this->belongsTo(Event::class);
    }
}

