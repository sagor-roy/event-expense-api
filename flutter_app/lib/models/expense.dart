class Expense {
  final int id;
  final String title;
  final double amount;
  final String paidBy;
  final String status; // pending, approved, declined

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.status,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'],
      amount: double.parse(json['amount'].toString()),
      paidBy: json['paid_by'].toString(),
      status: json['status'],
    );
  }
}
