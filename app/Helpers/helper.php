<?php

use Illuminate\Http\JsonResponse;

if (!function_exists('custom_response')) {
    function custom_response($status, $data = [], $message = "", $code = 200): JsonResponse
    {
        return response()->json([
            'message' => $message,
            'status' => $status,
            'data' => $data,
        ], $code);
    }
}
