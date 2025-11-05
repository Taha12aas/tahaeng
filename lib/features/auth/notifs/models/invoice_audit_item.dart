class InvoiceAuditItem {
  final String id;
  final String warehouseId;
  final String? accountId;
  final String? accountName;
  final String type; // sale/buy/undoSell/undoBuy/order
  final DateTime date;
  final String? notes;
  final DateTime? createdAt;
  final bool checkedByAccountant;
  final DateTime? checkedAt;

  InvoiceAuditItem({
    required this.id,
    required this.warehouseId,
    this.accountId,
    this.accountName,
    required this.type,
    required this.date,
    this.notes,
    this.createdAt,
    required this.checkedByAccountant,
    this.checkedAt,
  });

  factory InvoiceAuditItem.fromMap(Map<String, dynamic> m) {
    final acc = m['accounts'] as Map<String, dynamic>?;
    return InvoiceAuditItem(
      id: m['id'] as String,
      warehouseId: m['warehouse_id'] as String,
      accountId: m['account_id'] as String?,
      accountName: acc != null ? acc['name'] as String? : null,
      type: m['type'] as String,
      date: DateTime.parse(m['date'].toString()),
      notes: m['notes'] as String?,
      createdAt: m['created_at'] != null ? DateTime.parse(m['created_at']) : null,
      checkedByAccountant: (m['checked_by_accountant'] as bool?) ?? false,
      checkedAt: m['checked_at'] != null ? DateTime.parse(m['checked_at']) : null,
    );
  }
}