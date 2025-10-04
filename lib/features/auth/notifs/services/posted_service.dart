import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tahaeng/features/auth/notifs/models/posted_invoice.dart';

class PostedService {
  final SupabaseClient sb;
  PostedService(this.sb);

  Future<List<PostedInvoice>> fetchPostedAll() async {
    final res = await sb
        .from('invoices')
        .select(r'''
      id, date, type, notes, created_at,
      accounts:account_id (name)
    ''')
        .eq('checked_by_accountant', true)
        .order('created_at', ascending: false);
    return (res as List)
        .map((e) => PostedInvoice.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
