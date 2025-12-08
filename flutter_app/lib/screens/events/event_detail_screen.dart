import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../providers/event_provider.dart';
import '../expenses/expense_list_tab.dart';
import '../summary/summary_tab.dart';
import 'edit_event_screen.dart';
import 'requests_tab.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final isOwner = event.owner == 'You';
    final tabs = [
      const Tab(text: 'Expenses'),
      const Tab(text: 'Summary'),
      if (isOwner) const Tab(text: 'Requests'),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(event.name),
          bottom: TabBar(tabs: tabs),
          actions: isOwner
              ? [
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final result = await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EditEventScreen(event: event),
                          ),
                        );
                        if (result == true) {
                          // Ideally we should refresh the previous screen or this screen.
                          // Since this is a StatelessWidget, we rely on Provider updates.
                          // But we might need to pop back if name changed significantly or just let Provider handle it.
                          // Actually, if we update, we might want to pop to list to see changes or stay here.
                          // Let's just pop to list for simplicity as the event object passed here is static.
                          Navigator.of(context).pop();
                        }
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Event'),
                            content: const Text('Are you sure you want to delete this event?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          try {
                            await Provider.of<EventProvider>(context, listen: false).deleteEvent(event.id);
                            Navigator.of(context).pop(); // Go back to list
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit Event'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete Event'),
                        ),
                      ];
                    },
                  ),
                ]
              : null,
        ),
        body: TabBarView(
          children: [
            ExpenseListTab(event: event),
            SummaryTab(event: event),
            if (isOwner) RequestsTab(event: event),
          ],
        ),
      ),
    );
  }
}
