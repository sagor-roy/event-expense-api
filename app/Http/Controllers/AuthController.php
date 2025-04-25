<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    public function login(Request $request): JsonResponse
    {
        $validate = Validator::make($request->all(), [
            'email' => 'required|string|email',
            'password' => 'required',
        ]);

        if ($validate->fails()) {
            return $this->response('error', $validate->errors(), 422, 'Invalid Validation!!');
        }

        if (!Auth::attempt(['email' => $request->email, 'password' => $request->password])) {
            return $this->response('error', [], 401, 'Your email or password doesn\'t match our record!!');
        }

        $user = $request->user();
        $user->makeHidden(['created_at', 'updated_at', 'email_verified_at']);
        $token = $user->createToken('token')->plainTextToken;

        return $this->response('success', ['user' => $user, 'token' => $token], 200, 'Successfully Login!!');
    }

    public function register(Request $request): JsonResponse
    {
        $validate = Validator::make($request->all(), [
            'email' => 'required|string|email|unique:users,email',
            'password' => 'required|string|min:6|max:25|confirmed',
            'name' => 'required|string'
        ]);

        if ($validate->fails()) {
            return $this->response('error', $validate->errors(), 422, 'Invalid Validation!!');
        }

        $validatedData = $validate->validated();
        $validatedData['password'] = Hash::make($validatedData['password']);
        $validatedData['role'] = 'user';

        $user = User::create($validatedData);
        Auth::login($user);
        $user = $request->user();
        $user->makeHidden(['created_at', 'updated_at', 'email_verified_at']);
        $token = $user->createToken('token')->plainTextToken;

        return $this->response('success', ['user' => $user, 'token' => $token], 200, 'Successfully Registration!!');
    }

    public function logout(Request $request): JsonResponse
    {
        $user = $request->user();
        $user->tokens()->delete();

        return $this->response('success', [], 200, 'Successfully Logout!!');
    }
}
