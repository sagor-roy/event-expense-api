<?php

namespace App\Http\Controllers;

abstract class Controller
{
    public function response($status, $data = [], $code, $message = "")
    {
        return response()->json([
            'status' => $status,
            'message' => $message,
            'data' => $data
        ], $code);
    }
}
