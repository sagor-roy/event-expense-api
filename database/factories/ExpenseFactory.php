<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Expense>
 */
class ExpenseFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'event_id' => rand(1, 500),
            'paid_by' => rand(1, 50),
            'title' => $this->faker->word(),
            'amount' => $this->faker->randomFloat(2, 0, 1000),
            'note' => $this->faker->sentence(),
            'status' => $this->faker->randomElement(['pending', 'approved', 'declined']),
        ];
    }
}
