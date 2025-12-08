<?php

use Illuminate\Auth\AuthenticationException;
use Illuminate\Database\Eloquent\RelationNotFoundException;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Exceptions\ThrottleRequestsException;
use Illuminate\Http\JsonResponse;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\MethodNotAllowedHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;
use Symfony\Component\Routing\Exception\RouteNotFoundException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__ . '/../routes/web.php',
        api: __DIR__ . '/../routes/api.php',
        commands: __DIR__ . '/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        $middleware->api(prepend: [
            \Laravel\Sanctum\Http\Middleware\EnsureFrontendRequestsAreStateful::class,
        ]);

        $middleware->alias([
            'verified' => \App\Http\Middleware\EnsureEmailIsVerified::class,
        ]);

        $middleware->statefulApi();

        //
    })
    ->withExceptions(function (Exceptions $exceptions) {
        
        $exceptions->render(function (NotFoundHttpException $e,) {
            return custom_response('fail', [], $e->getMessage(), 401);
        });

        $exceptions->render(function (RouteNotFoundException $e,) {
            return custom_response('fail', [], $e->getMessage(), 401);
        });

        $exceptions->render(function (AuthenticationException $e,) {
            return custom_response('fail', [], $e->getMessage(), 401);
        });

        $exceptions->render(function (AccessDeniedHttpException $e,) {
            return custom_response('fail', [], $e->getMessage(), 401);
        });

        $exceptions->render(function (ThrottleRequestsException $e,) {
            return custom_response('fail', [], $e->getMessage(), 429);
        });

        $exceptions->render(function (MethodNotAllowedHttpException $e,) {
            return custom_response('fail', [], $e->getMessage(), 429);
        });

        $exceptions->render(function (RelationNotFoundException $e,) {
            return custom_response('fail', [], $e->getMessage(), 429);
        });
    })->create();
    

// function custom_response($status, $data = [], $message = "", $code = 200): JsonResponse
// {
//     return response()->json(['message' => $message, 'status' => $status, 'data' => $data], $code);
// }
