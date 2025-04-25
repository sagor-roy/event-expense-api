<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Expense extends Model
{
    protected $fillable = ['event_id', 'paid_by', 'title', 'amount', 'note', 'status'];

    public function event()
    {
        return $this->belongsTo(Event::class);
    }
    
    public function payer()
    {
        return $this->belongsTo(User::class, 'paid_by');
    }
    
}
