// lib/admin/services/membership_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/warehouse_member.dart';

class MembershipService {
  final SupabaseClient _sb;
  MembershipService(this._sb);

  Future<List<WarehouseMember>> fetchMembers(String warehouseId) async {
    final rows = await _sb
        .from('user_warehouses')
        .select('user_id, role, created_at, users:user_id (id, email, full_name, login_enabled)')
        .eq('warehouse_id', warehouseId)
        .order('created_at', ascending: true);
    return (rows as List).map((e) => WarehouseMember.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> addMemberByEmail(String warehouseId, String email) async {
    await _sb.rpc('assign_user_to_warehouse_strict', params: {
      'p_email': email,
      'p_warehouse_id': warehouseId,
    });
  }

  Future<void> removeMember(String warehouseId, String userId) async {
    await _sb
        .from('user_warehouses')
        .delete()
        .eq('warehouse_id', warehouseId)
        .eq('user_id', userId);
  }

  Future<void> setLoginEnabledByUserId(String userId, bool enabled) async {
    await _sb.from('users').update({'login_enabled': enabled}).eq('id', userId);
  }
}