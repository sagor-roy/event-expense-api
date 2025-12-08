class MemberSummary {
  final int id;
  final String name;
  final double expense;
  final double avgExpense;
  final double payable;
  final double receivable;

  MemberSummary({
    required this.id,
    required this.name,
    required this.expense,
    required this.avgExpense,
    required this.payable,
    required this.receivable,
  });

  factory MemberSummary.fromJson(Map<String, dynamic> json) {
    return MemberSummary(
      id: json['id'],
      name: json['name'],
      expense: double.parse(json['expense'].toString()),
      avgExpense: double.parse(json['avg_expense'].toString()),
      payable: double.parse(json['payable'].toString()),
      receivable: double.parse(json['receivable'].toString()),
    );
  }
}

class EventSummary {
  final List<MemberSummary> membersSummary;
  final double totalAmount;
  final int totalMembers;
  final double averageExpense;

  EventSummary({
    required this.membersSummary,
    required this.totalAmount,
    required this.totalMembers,
    required this.averageExpense,
  });

  factory EventSummary.fromJson(Map<String, dynamic> json) {
    var list = json['members_summary'] as List;
    List<MemberSummary> membersList = list.map((i) => MemberSummary.fromJson(i)).toList();

    return EventSummary(
      membersSummary: membersList,
      totalAmount: double.parse(json['total_amount'].toString()),
      totalMembers: int.parse(json['total_members'].toString()),
      averageExpense: double.parse(json['average_expense'].toString()),
    );
  }
}
