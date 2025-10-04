class PostedInvoice {
  final String id;
  final String date;
  final String type;
  final String? accountName;
  final DateTime createdAt;

  PostedInvoice({
    required this.id,
    required this.date,
    required this.type,
    this.accountName,
    required this.createdAt,
  });

  factory PostedInvoice.fromJson(Map<String, dynamic> json) {
    final acc = json['accounts'] as Map<String, dynamic>?;
    final created = DateTime.tryParse(json['created_at']?.toString() ?? '');
    return PostedInvoice(
      id: json['id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      accountName: acc?['name']?.toString() ?? json['account_name']?.toString(),
      createdAt: created ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}