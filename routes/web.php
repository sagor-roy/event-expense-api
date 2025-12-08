<?php

use App\Jobs\ActivateInactiveUsers;
use App\Jobs\SendOtp;
use App\Models\User;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return ['Laravel' => app()->version()];
});
