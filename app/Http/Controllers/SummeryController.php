<?php

namespace App\Http\Controllers;

use App\Models\Event;
use Illuminate\Http\Request;

class SummeryController extends Controller
{
    public function summery(Request $request, $event_code)
    {
        $event = Event::where('event_code', $event_code)->first();

        if (!$event) {
            return $this->response('error', null, 404, 'Event not found');
        }

        $members = $event->members()
            ->select('users.id', 'users.name')
            ->get();

        $userId = $request->user()->id;
        $isMember = $event->members->contains($userId);

        if (!$isMember) {
            return $this->response('error', null, 403, 'You are not authorized to access this event');
        }

        $total_amount = $event->expenses()->where('status', 'approved')->sum('amount');
        $total_members = $members->count();
        $average_expense = $total_members > 0 ? $total_amount / $total_members : 0;

        $member_summary = $members->map(function ($member) use ($event, $average_expense) {
            $member_expenses = $event->expenses()
                ->where('status', 'approved')
                ->where('paid_by', $member->id)
                ->sum('amount');

            $receive = $member_expenses > $average_expense ? $member_expenses - $average_expense : 0;
            $pay = $average_expense > $member_expenses ? $average_expense - $member_expenses : 0;

            return [
                'id' => $member->id,
                'name' => $member->name,
                'expense' => $member_expenses,
                'avg_expense' => round($average_expense, 2),
                'payable' => round($pay, 2),
                'receivable' => round($receive, 2),
            ];
        });

        return $this->response('success', [
            'members_summary' => $member_summary,
            'total_amount' => round($total_amount, 2),
            'total_members' => $total_members,
            'average_expense' => round($average_expense, 2),
        ], 200, 'Event summary retrieved successfully');
    }

    public function members(Request $request, $event_code)
    {
        $event = Event::where('event_code', $event_code)->first();

        if (!$event) {
            return $this->response('error', null, 404, 'Event not found');
        }

        $userId = $request->user()->id;
        $isMember = $event->members->contains($userId);

        if (!$isMember) {
            return $this->response('error', null, 403, 'You are not authorized to access this event');
        }

        $members = $event->members()
            ->select('users.id', 'users.name')
            ->get()
            ->each(function ($member) {
                unset($member->pivot);
            });;

        return $this->response('success', ['members' => $members], 200, 'Members retrieved successfully');
    }
}
