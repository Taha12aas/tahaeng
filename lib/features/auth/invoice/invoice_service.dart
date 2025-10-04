import 'package:supabase_flutter/supabase_flutter.dart';

class AcctInvoiceService {
  final SupabaseClient sb;
  AcctInvoiceService(this.sb);

  Future<Map<String, dynamic>> fetchInvoice(String id) async {
    final data = await sb
        .from('invoices')
        .select('''
          id, date, type, notes, checked_by_accountant,
          accounts:account_id (name),
          invoice_items (
            quantity,
            medicines:medicine_id (name, unit, internal_code)
          )
        ''')
        .eq('id', id)
        .single();

    return Map<String, dynamic>.from(data as Map);
  }
}
