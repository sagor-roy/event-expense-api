class JoinRequest {
  final int id;
  final String userName;
  final String eventName;
  final String status;
  final String createdAt;

  JoinRequest({
    required this.id,
    required this.userName,
    required this.eventName,
    required this.status,
    required this.createdAt,
  });

  factory JoinRequest.fromJson(Map<String, dynamic> json) {
    return JoinRequest(
      id: json['id'],
      userName: json['user_name'],
      eventName: json['event_name'],
      status: json['status'],
      createdAt: json['created_at'],
    );
  }
}
