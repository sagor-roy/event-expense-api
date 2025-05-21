<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\EventController;
use App\Http\Controllers\EventJoinRequestController;
use App\Http\Controllers\ExpenseController;
use App\Http\Controllers\SummeryController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;




Route::prefix('v1')->group(function () {
    Route::post('/login', [AuthController::class, 'login']); //->middleware(['throttle:6,1']);
    Route::post('/register', [AuthController::class, 'register']);

    Route::middleware(['auth:sanctum'])->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::apiResource('/event', EventController::class)->only(['store', 'update', 'destroy', 'index']);

        Route::get('/event/members/{event_code}', [SummeryController::class, 'members']);
        Route::get('/event/summery/{event_code}', [SummeryController::class, 'summery']);

        Route::post('/join/{event_code}', [EventJoinRequestController::class, 'storeJoinRequest']);
        Route::post('/join/{event_code}/{request_id}/accept', [EventJoinRequestController::class, 'acceptJoinRequest']);
        Route::post('/join/{event_code}/{request_id}/reject', [EventJoinRequestController::class, 'rejectJoinRequest']);
        Route::get('/join/request_list/{event_code}', [EventJoinRequestController::class, 'listJoinRequests']);

        Route::post('/expense/{event_id}', [ExpenseController::class, 'store']);
        Route::put('/expense/{expense_id}', [ExpenseController::class, 'update']);
        Route::put('/expense/{expense_id}/status', [ExpenseController::class, 'updateStatus']);
        Route::get('/expense/list/{event_code}', [SummeryController::class, 'expenseList']);
        
    });
});