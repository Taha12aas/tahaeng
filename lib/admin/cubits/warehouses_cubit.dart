// lib/admin/cubits/warehouses_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/warehouse_service.dart';
import '../models/warehouse.dart';
import 'warehouses_state.dart';

class WarehousesCubit extends Cubit<WarehousesState> {
  final WarehouseService svc;
  WarehousesCubit(this.svc) : super(const WarehousesState());

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final list = await svc.fetchAll();
      emit(state.copyWith(
        loading: false,
        items: list,
        selectedId: list.isNotEmpty ? list.first.id : null,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<Warehouse?> create(String name, {String? ownerEmail, String ownerRole = 'owner'}) async {
    try {
      final wh = await svc.create(name, ownerEmail: ownerEmail, ownerRole: ownerRole);
      await load();
      return wh;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return null;
    }
  }

  Future<void> rename(String id, String newName) async {
    await svc.rename(id, newName);
    await load();
  }

  Future<void> delete(String id) async {
    await svc.delete(id);
    await load();
  }

  void select(String id) {
    emit(state.copyWith(selectedId: id));
  }
}