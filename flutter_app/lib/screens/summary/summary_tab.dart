import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../providers/expense_provider.dart';

class SummaryTab extends StatefulWidget {
  final Event event;

  const SummaryTab({super.key, required this.event});

  @override
  State<SummaryTab> createState() => _SummaryTabState();
}

class _SummaryTabState extends State<SummaryTab> {
  @override
  void initState() {
    super.initState();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    try {
      await Provider.of<ExpenseProvider>(context, listen: false).fetchSummary(widget.event.eventCode);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load summary: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final summary = expenseProvider.summary;

    if (expenseProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (summary == null) {
      return const Center(child: Text('No summary available'));
    }

    return RefreshIndicator(
      onRefresh: () => expenseProvider.fetchSummary(widget.event.eventCode),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('Total Amount: \$${summary.totalAmount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text('Total Members: ${summary.totalMembers}'),
                    Text('Average per person: \$${summary.averageExpense.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Member Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: summary.membersSummary.length,
              itemBuilder: (context, index) {
                final member = summary.membersSummary[index];
                return Card(
                  child: ListTile(
                    title: Text(member.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Spent: \$${member.expense.toStringAsFixed(2)}'),
                        if (member.payable > 0)
                          Text('To Pay: \$${member.payable.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.red)),
                        if (member.receivable > 0)
                          Text('To Receive: \$${member.receivable.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.green)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
