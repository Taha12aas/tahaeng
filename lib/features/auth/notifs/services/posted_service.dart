import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tahaeng/features/auth/notifs/models/posted_invoice.dart';

class PostedService {
  final SupabaseClient sb;
  PostedService(this.sb);

  String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<List<PostedInvoice>> fetchPostedPage({
    int limit = 30,
    DateTime? beforeCreatedAt,
    String? beforeId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    var query = sb
        .from('invoices')
        .select(r'''
          id, date, type, created_at,
          accounts:account_id (name)
        ''')
        .eq('checked_by_accountant', true);

    // فلترة من تاريخ إلى تاريخ (شامِل)
    if (fromDate != null) {
      query = query.gte('date', _fmtDate(fromDate));
    }
    if (toDate != null) {
      query = query.lte('date', _fmtDate(toDate));
    }

    // Keyset pagination: created_at desc, id desc
    if (beforeCreatedAt != null && beforeId != null) {
      final iso = beforeCreatedAt.toIso8601String();
      query = query.or(
        'created_at.lt.$iso,and(created_at.eq.$iso,id.lt.$beforeId)',
      );
    }

    final res = await query
        .order('created_at', ascending: false)
        .order('id', ascending: false)
        .limit(limit);

    final rows = (res as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    return rows.map(PostedInvoice.fromJson).toList();
  }
}