import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/warehouse.dart';

class WarehouseService {
  final SupabaseClient _sb;
  WarehouseService(this._sb);

  Future<List<Warehouse>> fetchAll() async {
    final rows = await _sb
        .from('warehouses')
        .select('id, name, created_at')
        .order('created_at', ascending: false);
    return (rows as List)
        .map((e) => Warehouse.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  // يدعم إنشاء عادي أو عبر RPC لتعيين مالك بالبريد
  Future<Warehouse> create(String name, {String? ownerEmail, String ownerRole = 'owner'}) async {
    if (ownerEmail == null || ownerEmail.isEmpty) {
      final row = await _sb
          .from('warehouses')
          .insert({'name': name})
          .select('id, name, created_at')
          .single();
      return Warehouse.fromMap(Map<String, dynamic>.from(row));
    } else {
      final res = await _sb.rpc('create_warehouse_with_owner', params: {
        'p_name': name,
        'p_owner_email': ownerEmail,
        'p_owner_role': ownerRole,
      });
      final id = res as String;
      final row = await _sb
          .from('warehouses')
          .select('id, name, created_at')
          .eq('id', id)
          .single();
      return Warehouse.fromMap(Map<String, dynamic>.from(row));
    }
  }

  Future<void> rename(String id, String newName) async {
    await _sb.from('warehouses').update({'name': newName}).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _sb.from('warehouses').delete().eq('id', id);
  }
}