import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahaeng/features/auth/notifs/cubit/posted_state/posted_state.dart';
import 'package:tahaeng/features/auth/notifs/models/posted_invoice.dart';
import 'package:tahaeng/features/auth/notifs/services/posted_service.dart';

class PostedCubit extends Cubit<PostedState> {
  final PostedService service;
  PostedCubit(this.service) : super(PostedInitial());

  final List<PostedInvoice> _items = [];
  DateTime? _cursorAt;
  String? _cursorId;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _isLoadingMore = false;

  // فلترة التاريخ
  DateTime? _fromDate;
  DateTime? _toDate;
  DateTime? get fromDate => _fromDate;
  DateTime? get toDate => _toDate;

  Future<void> load() async {
    emit(PostedLoading());
    _reset();
    try {
      final page = await service.fetchPostedPage(
        limit: 30,
        fromDate: _fromDate,
        toDate: _toDate,
      );
      _append(page);
      _updateCursorFromLast();
      _hasMore = page.isNotEmpty;
      emit(PostedLoaded(items: List.unmodifiable(_items), hasMore: _hasMore));
    } catch (e) {
      emit(PostedFailure(e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;
    _isLoadingMore = true;
    if (state is PostedLoaded) {
      emit((state as PostedLoaded).copyWith(isLoadingMore: true));
    }
    try {
      final page = await service.fetchPostedPage(
        limit: 30,
        beforeCreatedAt: _cursorAt,
        beforeId: _cursorId,
        fromDate: _fromDate,
        toDate: _toDate,
      );
      if (page.isEmpty) {
        _hasMore = false;
        if (state is PostedLoaded) {
          emit((state as PostedLoaded).copyWith(
            hasMore: false,
            isLoadingMore: false,
          ));
        }
        _isLoadingMore = false;
        return;
      }
      _append(page);
      _updateCursorFromLast();
      emit(PostedLoaded(
        items: List.unmodifiable(_items),
        hasMore: true,
        isLoadingMore: false,
      ));
    } catch (e) {
      if (state is PostedLoaded) {
        emit((state as PostedLoaded).copyWith(isLoadingMore: false));
      } else {
        emit(PostedFailure(e.toString()));
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> refresh() async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      _reset();
      final page = await service.fetchPostedPage(
        limit: 30,
        fromDate: _fromDate,
        toDate: _toDate,
      );
      _append(page);
      _updateCursorFromLast();
      _hasMore = page.isNotEmpty;
      emit(PostedLoaded(items: List.unmodifiable(_items), hasMore: _hasMore));
    } catch (e) {
      emit(PostedFailure(e.toString()));
    } finally {
      _isLoading = false;
    }
  }

  // ضبط الفلتر
  Future<void> setDateRange(DateTime? from, DateTime? to) async {
    _fromDate = from;
    _toDate = to;
    await refresh(); // إعادة تحميل الصفحة الأولى بالفلتر
  }

  Future<void> clearDateRange() async {
    await setDateRange(null, null);
  }

  void _reset() {
    _items.clear();
    _cursorAt = null;
    _cursorId = null;
    _hasMore = true;
  }

  void _append(List<PostedInvoice> page) {
    final exist = _items.map((e) => e.id).toSet();
    for (final it in page) {
      if (!exist.contains(it.id)) {
        _items.add(it);
      }
    }
  }

  void _updateCursorFromLast() {
    if (_items.isNotEmpty) {
      final last = _items.last;
      _cursorAt = last.createdAt;
      _cursorId = last.id;
    }
  }
}