class NotifGroup {
  final String invoiceId;
  final String kind;
  final int count;
  final String? accountName;
  final String? invoiceType;
  final String? invoiceDate;
  final DateTime? lastNotifAt;
  final String? createdByName; // جديد

  NotifGroup({
    required this.invoiceId,
    required this.kind,
    required this.count,
    this.accountName,
    this.invoiceType,
    this.invoiceDate,
    this.lastNotifAt,
    this.createdByName,
  });

  factory NotifGroup.fromMap(Map<String, dynamic> m) => NotifGroup(
    invoiceId: m['invoice_id'] as String,
    kind: (m['kind'] ?? 'new') as String,
    count: (m['count'] as num).toInt(),
    accountName: m['account_name'] as String?,
    invoiceType: m['invoice_type'] as String?,
    invoiceDate: m['invoice_date']?.toString(),
    lastNotifAt: m['last_notif_at'] != null ? DateTime.parse(m['last_notif_at']) : null,
    createdByName: m['created_by_name'] as String?,
  );
}