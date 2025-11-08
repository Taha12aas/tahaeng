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
          transfer_direction, transfer_peer_warehouse_id,
          accounts:account_id (id, name),
          users:created_by (full_name, email),
          from_wh:warehouse_id (id, name),
          to_wh:transfer_peer_warehouse_id (id, name),
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
