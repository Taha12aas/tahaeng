import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/warehouse.dart';
import '../services/warehouse_service.dart';

class WarehousePickerState {
  final bool loading;
  final List<Warehouse> warehouses;
  final String? selectedId;
  final String? error;
  const WarehousePickerState({
    this.loading = false,
    this.warehouses = const [],
    this.selectedId,
    this.error,
  });

  WarehousePickerState copyWith({
    bool? loading,
    List<Warehouse>? warehouses,
    String? selectedId,
    String? error,
  }) {
    return WarehousePickerState(
      loading: loading ?? this.loading,
      warehouses: warehouses ?? this.warehouses,
      selectedId: selectedId ?? this.selectedId,
      error: error,
    );
  }
}

class WarehousePickerCubit extends Cubit<WarehousePickerState> {
  WarehousePickerCubit(this._service) : super(const WarehousePickerState());
  final WarehouseService _service;

  bool _busy = false;

  Future<void> load() async {
    if (isClosed) return;
    if (_busy) return; // امنع تداخل
    _busy = true;

    if (!isClosed) {
      emit(state.copyWith(loading: true, error: null));
    }
    try {
      final list = await _service.fetchAll();
      if (isClosed) return; // لو الصفحة انتقلت أثناء الانتظار
      emit(
        state.copyWith(
          loading: false,
          warehouses: list,
          selectedId: list.isNotEmpty ? list.first.id : null,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(loading: false, error: e.toString()));
    } finally {
      _busy = false;
    }
  }

  void select(String id) {
    if (isClosed) return;
    emit(state.copyWith(selectedId: id));
  }
}
