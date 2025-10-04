class AccountantNotification {
  final String id;
  final String invoiceId;
  final String kind; // new | edit
  final DateTime createdAt;
  final String? accountName;
  final String? invoiceDate;
  final String? invoiceType;
  final bool checkedByAccountant;

  AccountantNotification({
    required this.id,
    required this.invoiceId,
    required this.kind,
    required this.createdAt,
    this.accountName,
    this.invoiceDate,
    this.invoiceType,
    required this.checkedByAccountant,
  });

  factory AccountantNotification.fromJson(Map<String, dynamic> json) {
    final inv = json['invoices'] as Map<String, dynamic>?;
    final acc = inv?['accounts'] as Map<String, dynamic>?;
    return AccountantNotification(
      id: json['id'] as String,
      invoiceId: json['invoice_id'] as String,
      kind: json['kind'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      accountName: acc?['name'] as String?,
      invoiceDate: inv?['date']?.toString(),
      invoiceType: inv?['type']?.toString(),
      checkedByAccountant: (inv?['checked_by_accountant'] as bool?) ?? false,
    );
  }
}