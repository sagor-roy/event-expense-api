import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../providers/expense_provider.dart';
import 'create_expense_screen.dart';

class ExpenseListTab extends StatefulWidget {
  final Event event;

  const ExpenseListTab({super.key, required this.event});

  @override
  State<ExpenseListTab> createState() => _ExpenseListTabState();
}

class _ExpenseListTabState extends State<ExpenseListTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ExpenseProvider>(context, listen: false).fetchExpenses(widget.event.eventCode));
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final isOwner = widget.event.owner == 'You';

    return Scaffold(
      body: expenseProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : expenseProvider.expenses.isEmpty
              ? const Center(child: Text('No expenses yet.'))
              : RefreshIndicator(
                  onRefresh: () => expenseProvider.fetchExpenses(widget.event.eventCode),
                  child: ListView.builder(
                    itemCount: expenseProvider.expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenseProvider.expenses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(expense.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Paid by: ${expense.paidBy}'),
                              const SizedBox(height: 4),
                              _buildStatusBadge(expense.status),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('\$${expense.amount.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              if (isOwner && expense.status == 'pending') ...[
                                IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green),
                                  onPressed: () {
                                    expenseProvider.updateExpenseStatus(expense.id, 'approved');
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    expenseProvider.updateExpenseStatus(expense.id, 'declined');
                                  },
                                ),
                              ]
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateExpenseScreen(event: widget.event),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        break;
      case 'declined':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
