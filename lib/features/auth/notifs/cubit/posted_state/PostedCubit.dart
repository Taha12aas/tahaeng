 
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/notification_service.dart';
import 'posted_state.dart';

class PostedCubit extends Cubit<PostedState> {
  PostedCubit(this._svc) : super(const PostedLoading());

  final NotificationService _svc;
  String? _warehouseId;
  DateTime? fromDate;
  DateTime? toDate;
  static const _pageSize = 30;
  int _offset = 0;
  bool _hasMore = true;
  List<Map<String, dynamic>> _items = [];

  void setWarehouse(String warehouseId, {bool reload = true}) {
    _warehouseId = warehouseId;
    if (reload) load();
  }

  Future<void> setDateRange(DateTime? from, DateTime? to) async {
    fromDate = from;
    toDate = to;
    await load();
  }

  Future<void> clearDateRange() async => setDateRange(null, null);

  Future<void> load() async {
    final wh = _warehouseId;
    if (wh == null) {
      emit(const PostedFailure('لم يتم تحديد مستودع'));
      return;
    }
    emit(const PostedLoading());
    try {
      _offset = 0;
      final rows = await _svc.fetchPosted(
        warehouseId: wh,
        from: fromDate,
        to: toDate,
        limit: _pageSize,
        offset: _offset,
      );
      _items = rows;
      _hasMore = rows.length == _pageSize;
      emit(PostedLoaded(items: _items, hasMore: _hasMore));
    } catch (e) {
      emit(PostedFailure(e.toString()));
    }
  }

  Future<void> refresh() => load();

  Future<void> loadMore() async {
    final st = state;
    if (st is! PostedLoaded || !_hasMore || _warehouseId == null) return;
    emit(st.copyWith(isLoadingMore: true));
    _offset += _pageSize;
    try {
      final rows = await _svc.fetchPosted(
        warehouseId: _warehouseId!,
        from: fromDate,
        to: toDate,
        limit: _pageSize,
        offset: _offset,
      );
      _items = [..._items, ...rows];
      _hasMore = rows.length == _pageSize;
      emit(PostedLoaded(items: _items, hasMore: _hasMore));
    } catch (e) {
      emit(PostedFailure(e.toString()));
    }
  }
}