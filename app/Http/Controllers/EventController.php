<?php

namespace App\Http\Controllers;

use App\Models\Event;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

/**
 * @group Event
 *
 * APIs for managing resources
 * 
 * @subgroupDescription Do stuff with events
 */
class EventController extends Controller
{
    public function index(Request $request)
    {
        $events = Event::where('owner_id', $request->user()->id)
            ->orWhereHas('members', function ($query) use ($request) {
                $query->where('user_id', $request->user()->id);
            })
            ->with('owner:id,name')
            ->orderBy('created_at', 'asc')
            ->get()
            ->map(function ($event) use ($request) {
                return [
                    'id' => $event->id,
                    'name' => $event->name,
                    'event_code' => $event->event_code,
                    'owner' => $request->user()->id === $event->owner_id ? 'You' : $event->owner->name,
                    'description' => $event->description,
                    'members_count' => $event->members()->count(),
                    'created_at' => $event->created_at->format('d-M-Y'),
                ];
            });

        return $this->response('success', ['events' => $events], 200, 'Events retrieved successfully');
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'event_code' => 'required|string|alpha_num|unique:events,event_code',
            'description' => 'nullable|string'
        ]);

        if ($validator->fails()) {
            return $this->response('error', $validator->errors(), 422, 'Validation failed');
        }

        $data = $validator->validated();

        $data['owner_id'] = $request->user()->id;
        $event = Event::create($data);

        $event->members()->attach($request->user()->id);

        return $this->response('success', ['event' => $event], 200, 'Event created successfully');
    }

    public function update(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'description' => 'nullable|string'
        ]);

        if ($validator->fails()) {
            return $this->response('error', $validator->errors(), 422, 'Validation failed');
        }

        $data = $validator->validated();

        $event = Event::find($id);

        if (!$event) {
            return $this->response('error', null, 404, 'Event not found');
        }

        if ($event->owner_id !== $request->user()->id) {
            return $this->response('error', null, 403, 'Unauthorized');
        }

        $event->update($data);

        return $this->response('success', ['event' => $event], 200, 'Event updated');
    }

    public function destroy(Request $request, $id)
    {
        $event = Event::find($id);

        if (!$event) {
            return $this->response('error', null, 404, 'Event not found');
        }

        if ($event->owner_id !== $request->user()->id) {
            return $this->response('error', null, 403, 'Unauthorized');
        }

        $event->delete();

        return $this->response('success', null, 200, 'You have successfully deleted the event');
    }
}
