import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../providers/expense_provider.dart';
import 'create_expense_screen.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_indicator.dart';

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
      backgroundColor: Colors.grey.shade50,
      body: expenseProvider.isLoading
          ? const LoadingIndicator(message: 'Loading expenses...')
          : expenseProvider.expenses.isEmpty
              ? EmptyState(
                  message: 'No expenses yet. Add one!',
                  icon: Icons.receipt_long_rounded,
                  actionLabel: 'Add Expense',
                  onAction: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            CreateExpenseScreen(event: widget.event),
                      ),
                    );
                  },
                )
              : RefreshIndicator(
                  onRefresh: () =>
                      expenseProvider.fetchExpenses(widget.event.eventCode),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: expenseProvider.expenses.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final expense = expenseProvider.expenses[index];
                      return Card(
                        elevation: 0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          expense.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Paid by: ${expense.paidBy}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: Colors.grey.shade600,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '\$${expense.amount.toStringAsFixed(2)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStatusBadge(expense.status),
                                  if (isOwner &&
                                      expense.status == 'pending') ...[
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.check_circle,
                                              color: Colors.green),
                                          onPressed: () {
                                            expenseProvider.updateExpenseStatus(
                                                expense.id, 'approved');
                                          },
                                          tooltip: 'Approve',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.cancel,
                                              color: Colors.red),
                                          onPressed: () {
                                            expenseProvider.updateExpenseStatus(
                                                expense.id, 'declined');
                                          },
                                          tooltip: 'Decline',
                                        ),
                                      ],
                                    )
                                  ]
                                ],
                              ),
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
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        icon = Icons.check_circle_outline_rounded;
        break;
      case 'declined':
        color = Colors.red;
        icon = Icons.highlight_off_rounded;
        break;
      default:
        color = Colors.orange;
        icon = Icons.pending_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
