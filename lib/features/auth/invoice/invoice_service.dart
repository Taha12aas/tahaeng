import 'package:supabase_flutter/supabase_flutter.dart';

class AcctInvoiceService {
  final SupabaseClient _sb;
  AcctInvoiceService(this._sb);

  Future<Map<String, dynamic>> fetchInvoice(String invoiceId) async {
    final row = await _sb
        .from('invoices')
        .select('''
          id, warehouse_id, account_id, created_by, type, date, notes, created_at,
          checked_by_accountant, checked_at,
          accounts:account_id (id, name),
          users:created_by (full_name, email),
          invoice_items (
            id, invoice_id, medicine_id, quantity,
            medicines:medicine_id (id, name, internal_code, barcode, unit)
          )
        ''')
        .eq('id', invoiceId)
        .single();

    return Map<String, dynamic>.from(row as Map);
  }
}
