class PostedInvoice {
  final String id;
  final String date;
  final String type;
  final String? accountName;
  final String? notes;

  PostedInvoice({
    required this.id,
    required this.date,
    required this.type,
    this.accountName,
    this.notes,
  });

  factory PostedInvoice.fromJson(Map<String, dynamic> json) {
    final accounts = json['accounts'] as Map<String, dynamic>?;

    return PostedInvoice(
      // toString للتعامل مع int/uuid/null
      id: json['id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      accountName: accounts?['name']?.toString(),
      notes: json['notes']?.toString(),
    );
  }
}
