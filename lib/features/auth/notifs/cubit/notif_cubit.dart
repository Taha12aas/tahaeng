import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahaeng/features/auth/notifs/services/notification_service.dart';
import 'notif_state.dart';

class NotifCubit extends Cubit<NotifState> {
  final NotificationService service;
  NotifCubit(this.service) : super(NotifInitial());

  Future<void> load() async {
    emit(NotifLoading());
    try {
      final items = await service.fetchUnread();
      final groups = service.groupByInvoice(items);
      emit(NotifSuccess(groups));
    } catch (e) {
      emit(NotifFailure(e.toString()));
    }
  }

  Future<void> refresh() async {
    try {
      final items = await service.fetchUnread();
      final groups = service.groupByInvoice(items);
      emit(NotifSuccess(groups));
    } catch (e) {
      emit(NotifFailure(e.toString()));
    }
  }

  Future<void> checkInvoice(String invoiceId) async {
    try {
      await service.checkInvoice(invoiceId); // RPC
      await refresh(); // حدّث غير مدقّقة
    } catch (e) {
      emit(NotifFailure(e.toString()));
    }
  }
}
