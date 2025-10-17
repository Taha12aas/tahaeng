class NotifGroup {
  final String invoiceId;
  final String kind; // أحدث نوع: new/edit
  final String? accountName;
  final String? invoiceDate;
  final String? invoiceType;
  final DateTime latestAt;
  final int count;

  NotifGroup({
    required this.invoiceId,
    required this.kind,
    required this.latestAt,
    required this.count,
    this.accountName,
    this.invoiceDate,
    this.invoiceType,
  });

  get checkedByAccountant => null;
}