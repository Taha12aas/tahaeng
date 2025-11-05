import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/invoice_audit_item.dart';

class InvoiceAuditService {
  final _sb = Supabase.instance.client;

  Future<List<InvoiceAuditItem>> fetchInvoices({
    required String warehouseId,
    required bool checked,
    int limit = 200,
  }) async {
    final data = await _sb
        .from('invoices')
        .select('id, warehouse_id, account_id, type, date, notes, created_at, checked_by_accountant, checked_at, accounts:account_id (name)')
        .eq('warehouse_id', warehouseId)
        .eq('checked_by_accountant', checked)
        .order('created_at', ascending: false)
        .limit(limit);
    return (data as List).map((e) => InvoiceAuditItem.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  // التحقق (mark checked) عبر RPC مع fallback
  Future<void> checkInvoice(String invoiceId) async {
    try {
      await _sb.rpc('fn_accountant_check_invoice', params: {'p_invoice_id': invoiceId});
    } catch (_) {
      // fallback: update مباشر (التريغر يسمح بالتحويل false->true فقط)
      await _sb.from('invoices').update({'checked_by_accountant': true}).eq('id', invoiceId);
    }
  }

  // إلغاء التحقق
  Future<void> uncheckInvoice(String invoiceId) async {
    try {
      await _sb.rpc('fn_accountant_uncheck_invoice', params: {'p_invoice_id': invoiceId});
    } catch (_) {
      await _sb.from('invoices').update({'checked_by_accountant': false, 'checked_at': null}).eq('id', invoiceId);
    }
  }
}