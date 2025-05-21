<?php

namespace Database\Seeders;

use App\Models\Event;
use App\Models\EventRequest;
use App\Models\Expense;
use App\Models\User;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        //User::factory()->count(50000)->create();
        //Event::factory()->count(1000)->create();

        // EventRequest::factory()->count(10000)->create()->each(function ($eventRequest) {
        //     if ($eventRequest->status === 'accepted') {
        //         $eventRequest->event->members()->attach($eventRequest->user_id);
        //     }
        // });

        Expense::factory()->count(10000)->create();
    }
}
