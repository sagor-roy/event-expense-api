<?php

namespace App\Http\Controllers;

use App\Models\Event;
use App\Models\Expense;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ExpenseController extends Controller
{
    public function store(Request $request, $event_id)
    {
        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255',
            'amount' => 'required|numeric|min:0.01',
            'note' => 'nullable|string'
        ]);

        if ($validator->fails()) {
            return $this->response('error', $validator->errors(), 422, 'Validation failed');
        }

        $data = $validator->validated();

        $event = Event::find($event_id);

        if (!$event) {
            return $this->response('error', [], 404, 'Event not found');
        }

        if (!$event->members->contains($request->user()->id)) {
            return $this->response('error', [], 403, 'You are not a member of this event');
        }

        $data['paid_by'] = $request->user()->id;
        $data['event_id'] = $event->id;
        $data['status'] = 'pending';

        $expense = Expense::create($data);

        return $this->response('success', ['expense' => $expense], 200, 'Expense added successfully');
    }

    public function update(Request $request, $expense_id)
    {
        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255',
            'amount' => 'required|numeric|min:0.01',
            'note' => 'nullable|string'
        ]);

        if ($validator->fails()) {
            return $this->response('error', $validator->errors(), 422, 'Validation failed');
        }

        $data = $validator->validated();

        $expense = Expense::where('id', $expense_id)->where('paid_by', $request->user()->id)->first();

        if (!$expense) {
            return $this->response('error', [], 404, 'Expense not found');
        }

        if ($expense->status === 'approved') {
            return $this->response('error', [], 403, 'You cannot edit an approved expense');
        }

        $expense->update($data);

        return $this->response('success', ['expense' => $expense], 200, 'Expense updated successfully');
    }

    public function updateStatus(Request $request, $expense_id)
    {
        $validator = Validator::make($request->all(), [
            'status' => 'required|in:approved,declined'
        ]);

        if ($validator->fails()) {
            return $this->response('error', $validator->errors(), 422, 'Validation failed');
        }

        $expense = Expense::find($expense_id);

        $event = $expense->event;
        if ($event->owner_id !== $request->user()->id) {
            return $this->response('error', [], 403, 'Only the event owner can approve/decline expenses');
        }

        if (!$expense) {
            return $this->response('error', [], 404, 'Expense not found');
        }
        if ($expense->status === 'approved') {
            return $this->response('error', [], 403, 'Expense already approved');
        }
        if ($expense->status === 'declined') {
            return $this->response('error', [], 403, 'Expense already declined');
        }

        $expense->status = $request->status;
        $expense->save();

        return $this->response('success', ['expense' => $expense], 200, 'Expense status updated');
    }

    public function expenseList(Request $request, $event_id)
    {
        $event = Event::find($event_id);

        if (!$event) {
            return $this->response('error', [], 404, 'Event not found');
        }

        if (!$event->members->contains($request->user()->id)) {
            return $this->response('error', [], 403, 'You are not a member of this event');
        }

        $expenses = Expense::where('event_id', $event_id)->get();

        return $this->response('success', ['expenses' => $expenses], 200, 'Expenses retrieved successfully');
    }
}
