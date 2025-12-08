import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../providers/event_provider.dart';

class RequestsTab extends StatefulWidget {
  final Event event;

  const RequestsTab({super.key, required this.event});

  @override
  State<RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<RequestsTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<EventProvider>(context, listen: false).fetchJoinRequests(widget.event.eventCode));
  }

  @override
  Widget build(BuildContext context) {
    // We need to handle the list locally or in provider. 
    // The provider has fetchJoinRequests which returns a list, but doesn't store it in a state variable for us to watch easily unless we add it.
    // Let's use FutureBuilder or update Provider.
    // Ideally Provider should hold the state.
    // But for now, let's use FutureBuilder for simplicity or just call fetch and store in local state.
    return FutureBuilder(
      future: Provider.of<EventProvider>(context, listen: false).fetchJoinRequests(widget.event.eventCode),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return const Center(child: Text('No pending requests'));
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text(request.userName),
                subtitle: Text('Requested: ${request.createdAt}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () async {
                        await Provider.of<EventProvider>(context, listen: false)
                            .acceptJoinRequest(widget.event.eventCode, request.id);
                        setState(() {}); // Refresh list
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        await Provider.of<EventProvider>(context, listen: false)
                            .rejectJoinRequest(widget.event.eventCode, request.id);
                        setState(() {}); // Refresh list
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
