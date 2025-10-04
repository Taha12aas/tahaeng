import 'package:collection/collection.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tahaeng/features/auth/notifs/models/accountant_notification.dart';
import 'package:tahaeng/features/auth/notifs/models/notif_group.dart';

class NotificationService {
  final SupabaseClient sb;
  NotificationService(this.sb);

  // جلب إشعارات غير مقروءة مع ربط الفاتورة والحساب
  Future<List<AccountantNotification>> fetchUnread() async {
    final res = await sb
        .from('accountant_notifications')
        .select('''
          id, invoice_id, kind, is_read, created_at,
          invoices:invoice_id (
            id, date, type, checked_by_accountant,
            accounts:account_id (name)
          )
        ''')
        .eq('is_read', false)
        .order('created_at', ascending: false);

    return (res as List)
        .map((e) => AccountantNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // تجميع الإشعارات حسب الفاتورة (لإظهار كرت واحد مع عدّاد تغييرات)
  List<NotifGroup> groupByInvoice(List<AccountantNotification> items) {
    final map = groupBy(items, (e) => e.invoiceId);
    final groups = <NotifGroup>[];
    map.forEach((invoiceId, list) {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final latest = list.first;
      groups.add(
        NotifGroup(
          invoiceId: invoiceId,
          kind: latest.kind,
          latestAt: latest.createdAt,
          count: list.length,
          accountName: latest.accountName,
          invoiceDate: latest.invoiceDate,
          invoiceType: latest.invoiceType,
        ),
      );
    });
    groups.sort((a, b) => b.latestAt.compareTo(a.latestAt));
    return groups;
  }

  // تدقيق فاتورة (RPC)
  Future<void> checkInvoice(String invoiceId) async {
    await sb.rpc(
      'fn_accountant_check_invoice',
      params: {'p_invoice_id': invoiceId},
    );
  }
}
