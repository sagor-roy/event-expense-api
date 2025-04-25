<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Event extends Model
{

    protected $fillable = ['name', 'event_code', 'owner_id', 'description'];

    public function owner()
    {
        return $this->belongsTo(User::class, 'owner_id');
    }

    public function members()
    {
        return $this->belongsToMany(User::class)->withTimestamps();
    }

    public function requests()
    {
        return $this->hasMany(EventRequest::class);
    }

    public function expenses()
    {
        return $this->hasMany(Expense::class);
    }
}

