import '../models/warehouse_member.dart';

class MembersState {
  final bool loading;
  final List<WarehouseMember> items;
  final String? warehouseId;
  final String? warehouseName;
  final String? error;

  const MembersState({
    this.loading = false,
    this.items = const [],
    this.warehouseId,
    this.warehouseName,
    this.error,
  });

  MembersState copyWith({
    bool? loading,
    List<WarehouseMember>? items,
    String? warehouseId,
    String? warehouseName,
    String? error,
  }) =>
      MembersState(
        loading: loading ?? this.loading,
        items: items ?? this.items,
        warehouseId: warehouseId ?? this.warehouseId,
        warehouseName: warehouseName ?? this.warehouseName,
        error: error,
      );
}

const kRoles = ['owner', 'manager', 'accountant', 'clerk', 'viewer'];