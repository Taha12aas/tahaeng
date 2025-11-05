import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/warehouse.dart';

class WarehouseService {
  final _sb = Supabase.instance.client;

  Future<List<Warehouse>> fetchAll() async {
    final rows = await _sb.from('warehouses').select('id, name, created_at').order('name');
    return (rows as List).map((e) => Warehouse.fromMap(Map<String, dynamic>.from(e))).toList();
  }
}