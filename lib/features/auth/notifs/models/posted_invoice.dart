class PostedInvoice {
  final String id;
  final String date;
  final String type;
  final String? accountName;
  final DateTime createdAt; // جديد

  PostedInvoice({
    required this.id,
    required this.date,
    required this.type,
    this.accountName,
    required this.createdAt,
  });

  factory PostedInvoice.fromJson(Map<String, dynamic> json) {
    return PostedInvoice(
      id: json['id'] as String,
      date: json['date']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      accountName: json['accounts']?['name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String), // مهم
    );
  }
}