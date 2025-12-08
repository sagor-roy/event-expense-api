<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;

class AuthControllerTest extends TestCase
{
    use RefreshDatabase, WithFaker;
    /**
     * A basic feature test example.
     */

    public function test_get_login_validation_errors()
    {
        $response = $this->postJson('/api/v1/login', [
            'email' => '',
            'password' => '',
        ]);

        $response->assertStatus(422)
            ->assertJson([
                'status' => 'error',
                'message' => 'Invalid Validation!!',
                'data' => [
                    'email' => [
                        'The email field is required.'
                    ],
                    'password' => [
                        'The password field is required.'
                    ]
                ]
            ]);
    }

    public function test_invalid_login_email_format()
    {
        $response = $this->postJson('/api/v1/login', [
            'email' => 'invalid-email',
            'password' => '12345678',
        ]);
        $response->assertStatus(422)
            ->assertJson([
                'status' => 'error',
                'message' => 'Invalid Validation!!',
            ]);
    }

    public function test_user_email_or_password_not_exist()
    {
        $response = $this->postJson('/api/v1/login', [
            'email' => 'xyz@gmail.com',
            'password' => '12345678',
        ]);
        $response->assertStatus(401)
            ->assertJson([
                'status' => 'error',
                'message' => "Your email or password doesn't match our record!!",
                'data' => []
            ]);
    }

    public function test_user_successfully_login()
    {
        $user = \App\Models\User::factory()->create([
            'email' =>  $this->faker->unique()->safeEmail(),
            'name' => $this->faker->name(),
            'password' => bcrypt('12345678'),
        ]);
        $response = $this->postJson('/api/v1/login', [
            'email' => $user->email,
            'password' => '12345678',
        ]);
        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
                'message' => 'Successfully Login!!',
            ]);
    }
}
