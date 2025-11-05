import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notif_group.dart';

class NotificationService {
  final SupabaseClient _sb;
  NotificationService(this._sb);

  // إشعارات غير مدققة (مجموعة بحسب الفاتورة)
  Future<List<NotifGroup>> fetchUnreviewedGroups(String warehouseId) async {
    final data = await _sb
        .from('accountant_notifications')
        .select('''
        invoice_id,
        invoices!inner (
          warehouse_id, date, type, account_id, created_by,
          accounts:account_id (name),
          users:created_by (full_name, email)
        ),
        kind,
        created_at
      ''')
        .eq('invoices.warehouse_id', warehouseId)
        .eq('invoices.checked_by_accountant', false)
        .order('created_at', ascending: false);

    final Map<String, Map<String, dynamic>> acc = {};
    for (final row in (data as List)) {
      final inv = row['invoices'] as Map<String, dynamic>;
      final id = row['invoice_id'] as String;
      final kind = (row['kind'] ?? 'new') as String;
      final createdAt = DateTime.parse(row['created_at']);

      final creator = inv['users'] as Map<String, dynamic>?;
      final creatorName = (creator?['full_name'] as String?)?.trim();
      final creatorEmail = (creator?['email'] as String?)?.trim();
      final displayCreator = (creatorName?.isNotEmpty ?? false)
          ? creatorName
          : (creatorEmail?.isNotEmpty ?? false ? creatorEmail : null);

      final entry = acc.putIfAbsent(
        id,
        () => {
          'invoice_id': id,
          'kind': 'new',
          'count': 0,
          'account_name': (inv['accounts']?['name']) as String?,
          'invoice_type': inv['type'] as String?,
          'invoice_date': inv['date']?.toString(),
          'created_by_name': displayCreator,
          'last_notif_at': createdAt.toIso8601String(),
        },
      );

      entry['count'] = (entry['count'] as int) + 1;
      if (kind == 'edit') entry['kind'] = 'edit';

      final last = DateTime.parse(entry['last_notif_at'] as String);
      if (createdAt.isAfter(last)) {
        entry['last_notif_at'] = createdAt.toIso8601String();
      }
    }

    final list = acc.values
        .map(
          (m) => NotifGroup.fromMap({
            'invoice_id': m['invoice_id'],
            'kind': m['kind'],
            'count': m['count'],
            'account_name': m['account_name'],
            'invoice_type': m['invoice_type'],
            'invoice_date': m['invoice_date'],
            'created_by_name': m['created_by_name'],
            'last_notif_at': m['last_notif_at'],
          }),
        )
        .toList();

    list.sort(
      (a, b) => (b.lastNotifAt ?? DateTime(0)).compareTo(
        a.lastNotifAt ?? DateTime(0),
      ),
    );
    return list;
  }

  Future<void> markChecked(String invoiceId) async {
    try {
      await _sb.rpc(
        'fn_accountant_check_invoice',
        params: {'p_invoice_id': invoiceId},
      );
    } catch (_) {
      await _sb
          .from('invoices')
          .update({'checked_by_accountant': true})
          .eq('id', invoiceId);
    }
  }

  Future<List<Map<String, dynamic>>> fetchPosted({
    required String warehouseId,
    DateTime? from,
    DateTime? to,
    required int limit,
    required int offset,
  }) async {
    var q = _sb
        .from('invoices')
        .select('''
        id, account_id, type, date, created_at, created_by,
        accounts:account_id (name),
        users:created_by (full_name, email)
      ''')
        .eq('warehouse_id', warehouseId)
        .eq('checked_by_accountant', true);

    if (from != null) q = q.gte('date', _fmt(from));
    if (to != null) q = q.lte('date', _fmt(to));

    final rows = await q
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return List<Map<String, dynamic>>.from(rows as List);
  }
}

String _fmt(DateTime dt) =>
    '${dt.year.toString().padLeft(4, '0')}-'
    '${dt.month.toString().padLeft(2, '0')}-'
    '${dt.day.toString().padLeft(2, '0')}';
