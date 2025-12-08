import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import 'event_detail_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<EventProvider>(context, listen: false).fetchEvents());
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        actions: [
          if (authProvider.user != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  authProvider.user!.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
            },
          ),
        ],
      ),
      body: eventProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : eventProvider.events.isEmpty
              ? const Center(child: Text('No events found. Create or Join one!'))
              : RefreshIndicator(
                  onRefresh: () => eventProvider.fetchEvents(),
                  child: ListView.builder(
                    itemCount: eventProvider.events.length,
                    itemBuilder: (context, index) {
                      final event = eventProvider.events[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(event.name),
                          subtitle: Text('Code: ${event.eventCode}\nOwner: ${event.owner}'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          isThreeLine: true,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EventDetailScreen(event: event),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'join',
            onPressed: () {
              Navigator.of(context).pushNamed('/join-event');
            },
            label: const Text('Join'),
            icon: const Icon(Icons.group_add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'create',
            onPressed: () {
              Navigator.of(context).pushNamed('/create-event');
            },
            label: const Text('Create'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
