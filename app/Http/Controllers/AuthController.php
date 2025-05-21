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
    /**
     * User Login
     * 
     * Authenticates a user and returns a token.
     * 
     * @unauthenticated
     * @bodyParam email string required The email of the user. Example:
     * @bodyParam password string required The password of the user. Example: secret123
     * 
     * @response 200 {
     *   "status": "success",
     *   "message": "Successfully Registration!!",
     *   "data": {
     *     "user": {
     *       "id": 1,
     *       "name": "John Doe",
     *       "email": "john@example.com"
     *     },
     *     "token": "token-value"
     *   }
     * }
     * 
     * @response 401 {
     *   "status": "error",
     *   "message": "Your email or password doesn't match our record!!",
     *   "data": []
     * }
     * 
     * @response 422 {
     *   "status": "error",
     *   "message": "Invalid Validation!!",
     *   "data": {
     *     "email": [
     *       "The email field is required."
     *     ],
     *     "password": [
     *       "The password field is required."
     *     ]
     *   }
     * }
     * 
     */
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

    /**
     * User Registration
     * 
     * Registers a new user and returns a token.
     * 
     * @unauthenticated
     * @bodyParam name string required The name of the user. Example: John Doe
     * @bodyParam email string required The email of the user. Must be unique. Example: john@example.com
     * @bodyParam password string required The password. Must be confirmed. Min 6 characters. Example: secret123
     * @bodyParam password_confirmation string required The confirmation of the password. Example: secret123
     *
     * @response 200 {
     *   "status": "success",
     *   "message": "Successfully Registration!!",
     *   "data": {
     *     "user": {
     *       "id": 1,
     *       "name": "John Doe",
     *       "email": "john@example.com"
     *     },
     *     "token": "token-value"
     *   }
     * }
     */
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

    /**
     * User Logout
     * 
     * Logs out the user and deletes the token.
     * 
     * @authenticated
     * 
     * @response 200 {
     *   "status": "success",
     *   "message": "Successfully Logout!!",
     *   "data": []
     * }
     */
    

    public function logout(Request $request): JsonResponse
    {
        $user = $request->user();
        $user->tokens()->delete();

        return $this->response('success', [], 200, 'Successfully Logout!!');
    }
}
