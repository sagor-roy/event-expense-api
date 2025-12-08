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

        $responseExpense = [
            'id' => $expense->id,
            'title' => $expense->title,
            'amount' => round($expense->amount, 2),
            'paid_by' => $request->user()->name,
            'status' => $expense->status,
        ];

        return $this->response('success', ['expense' => $responseExpense], 200, 'Expense added successfully');
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

        $responseExpense = [
            'id' => $expense->id,
            'title' => $expense->title,
            'amount' => round($expense->amount, 2),
            'paid_by' => $request->user()->name,
            'status' => $expense->status,
        ];

        return $this->response('success', ['expense' => $responseExpense], 200, 'Expense updated successfully');
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

        $responseExpense = [
            'id' => $expense->id,
            'title' => $expense->title,
            'amount' => round($expense->amount, 2),
            'paid_by' => $expense->payer->name, // Assuming 'payer' relation exists, or we fetch user. 
            // Actually, 'payer' relation is used in 'expenseList' in SummeryController.
            // Let's check Expense model if 'payer' exists or use 'user'.
            // In SummeryController: $event->expenses()->with('payer:id,name')
            // So 'payer' relation likely exists.
            'status' => $expense->status,
        ];

        return $this->response('success', ['expense' => $responseExpense], 200, 'Expense status updated');
    }
}
