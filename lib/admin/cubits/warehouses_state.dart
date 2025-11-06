import '../models/warehouse.dart';

class WarehousesState {
  final bool loading;
  final List<Warehouse> items;
  final String? selectedId;
  final String? error;

  const WarehousesState({
    this.loading = false,
    this.items = const [],
    this.selectedId,
    this.error,
  });

  WarehousesState copyWith({
    bool? loading,
    List<Warehouse>? items,
    String? selectedId,
    String? error,
  }) => WarehousesState(
    loading: loading ?? this.loading,
    items: items ?? this.items,
    selectedId: selectedId ?? this.selectedId,
    error: error,
  );
}
