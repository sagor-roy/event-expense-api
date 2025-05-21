<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Event>
 */
class EventFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'name' => $this->faker->word(),
            'event_code' => strtoupper($this->faker->unique()->bothify('EVENT_##??')),
            'owner_id' => rand(1, 50),
            'description' => $this->faker->sentence(),
        ];
    }
}
