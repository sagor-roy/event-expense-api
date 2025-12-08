<?php

namespace App\Jobs;

use App\Models\User;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;

class ActivateInactiveUsers implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public $tries = 3;
    public $timeout = 1200;
    public $maxExceptions = 2;

    public function handle()
    {
        Log::info('Activating inactive users...');

        User::where('status', 'inactive')
            ->chunkById(500, function ($users) {
                foreach ($users as $user) {
                    $user->status = 'active';
                    $user->save();
                }
            });
        Log::info('Inactive users activated successfully.');

    }

    public function failed(\Exception $exception)
    {
        Log::error('User activation failed: ' . $exception->getMessage());
    }
}
