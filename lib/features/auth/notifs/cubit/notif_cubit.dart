import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/notification_service.dart';
import 'notif_state.dart';

class NotifCubit extends Cubit<NotifState> {
  NotifCubit(this._svc) : super(const NotifInitial());
  final NotificationService _svc;
  String? _warehouseId;

  void setWarehouse(String warehouseId, {bool reload = true}) {
    _warehouseId = warehouseId;
    if (reload) load();
  }

  Future<void> load() async {
    final wh = _warehouseId;
    if (wh == null) {
      emit(const NotifFailure('لم يتم تحديد مستودع'));
      return;
    }
    emit(const NotifLoading());
    try {
      final groups = await _svc.fetchUnreviewedGroups(wh);
      emit(NotifSuccess(groups));
    } catch (e) {
      emit(NotifFailure(e.toString()));
    }
  }

  Future<void> refresh() => load();

  Future<void> checkInvoice(String invoiceId) async {
    await _svc.markChecked(invoiceId);
    await load(); // بعد التدقيق تنحدف من قائمة غير المدققة
  }
}
