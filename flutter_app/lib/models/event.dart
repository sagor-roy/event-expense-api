class Event {
  final int id;
  final String name;
  final String eventCode;
  final String owner; // "You" or name
  final String? description;
  final int membersCount;
  final String createdAt;

  Event({
    required this.id,
    required this.name,
    required this.eventCode,
    required this.owner,
    this.description,
    required this.membersCount,
    required this.createdAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      name: json['name'],
      eventCode: json['event_code'],
      owner: json['owner'],
      description: json['description'],
      membersCount: json['members_count'],
      createdAt: json['created_at'],
    );
  }
}
