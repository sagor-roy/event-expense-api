<?php

namespace Tests\Feature;

use App\Models\Event;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class SummeryControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_owner_can_view_event_summary()
    {
        $owner = User::factory()->create();

        $event = Event::create([
            'name' => 'Owner Event',
            'event_code' => 'own123',
            'owner_id' => $owner->id,
            'description' => 'Owner event',
        ]);

        $response = $this->actingAs($owner)->getJson('/api/v1/event/summery/' . $event->event_code);

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
            ]);
    }

    public function test_member_can_view_event_summary()
    {
        $owner = User::factory()->create();
        $member = User::factory()->create();

        $event = Event::create([
            'name' => 'Member Event',
            'event_code' => 'mem123',
            'owner_id' => $owner->id,
            'description' => 'Member event',
        ]);

        $event->members()->attach($member->id);

        $response = $this->actingAs($member)->getJson('/api/v1/event/summery/' . $event->event_code);

        $response->assertStatus(200)
            ->assertJson([
                'status' => 'success',
            ]);
    }

    public function test_non_member_and_non_owner_cannot_view_summary()
    {
        $owner = User::factory()->create();
        $stranger = User::factory()->create();

        $event = Event::create([
            'name' => 'Private Event',
            'event_code' => 'private123',
            'owner_id' => $owner->id,
            'description' => 'Not for strangers',
        ]);

        $response = $this->actingAs($stranger)->getJson('/api/v1/event/summery/' . $event->event_code);

        $response->assertStatus(403)
            ->assertJson([
                'status' => 'error',
            ]);
    }
}
