<?php

namespace App\Http\Controllers;

use App\Models\Event;
use App\Models\EventRequest;
use Illuminate\Http\Request;

class EventJoinRequestController extends Controller
{
    public function storeJoinRequest(Request $request, $event_code)
    {
        $user = $request->user();
        $event = Event::where('event_code', $event_code)->first();

        if (!$event) {
            return $this->response(false, [], 404, 'Event not found');
        }

        if ($event->members()->where('user_id', $user->id)->exists()) {
            return $this->response(false, [], 400, 'You are already a member of this event');
        }

        if ($event->requests()->where('user_id', $user->id)->exists()) {
            return $this->response(false, [], 400, 'You have already requested to join this event');
        }

        $requestJoin = new EventRequest();
        $requestJoin->user_id = $user->id;
        $requestJoin->event_id = $event->id;
        $requestJoin->status = 'pending';
        $requestJoin->save();

        return $this->response(true, [], 201, 'Request to join event sent successfully');
    }

    public function acceptJoinRequest(Request $request, $event_code, $request_id)
    {
        $user = $request->user();
        $event = Event::where('event_code', $event_code)->first();

        if (!$event) {
            return $this->response(false, [], 404, 'Event not found');
        }

        if ($event->owner_id !== $user->id) {
            return $this->response(false, [], 403, 'Unauthorized');
        }

        $joinRequest = EventRequest::find($request_id);

        if (!$joinRequest || $joinRequest->event_id !== $event->id) {
            return $this->response(false, [], 404, 'Join request not found');
        }

        if ($joinRequest->status !== 'pending') {
            return $this->response(false, [], 400, 'Join request already processed');
        }

        $joinRequest->status = 'accepted';
        $joinRequest->save();

        $event->members()->attach($joinRequest->user_id);

        return $this->response(true, [], 200, 'Join request accepted successfully');
    }

    public function rejectJoinRequest(Request $request, $event_code, $request_id)
    {
        $user = $request->user();
        $event = Event::where('event_code', $event_code)->first();

        if (!$event) {
            return $this->response(false, [], 404, 'Event not found');
        }

        if ($event->owner_id !== $user->id) {
            return $this->response(false, [], 403, 'Unauthorized');
        }

        $joinRequest = EventRequest::find($request_id);

        if (!$joinRequest || $joinRequest->event_id !== $event->id) {
            return $this->response(false, [], 404, 'Join request not found');
        }

        if ($joinRequest->status !== 'pending') {
            return $this->response(false, [], 400, 'Join request already processed');
        }

        $joinRequest->status = 'rejected';
        $joinRequest->save();

        return $this->response(true, [], 200, 'Join request rejected successfully');
    }

    public function listJoinRequests(Request $request, $event_code)
    {
        $user = $request->user();
        $event = Event::where('event_code', $event_code)->first();

        if (!$event) {
            return $this->response(false, [], 404, 'Event not found');
        }

        if ($event->owner_id !== $user->id) {
            return $this->response(false, [], 403, 'Unauthorized');
        }

        $joinRequests = EventRequest::where('event_id', $event->id)
        ->with('event:id,name', 'user:id,name')
        ->where('status', 'pending')
        ->get()
        ->map(function ($item) {
            return [
                'id' => $item->id,
                'user_name' => $item->user->name,
                'event_name' => $item->event->name,
                'status' => $item->status,
                'created_at' => $item->created_at->format('Y-m-d H:i:s'),
            ];
        });

        return $this->response(true, ['requests' => $joinRequests], 200, 'Join requests retrieved successfully');
    }
}
