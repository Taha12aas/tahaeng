// lib/admin/cubits/members_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/membership_service.dart';
import 'members_state.dart';

class MembersCubit extends Cubit<MembersState> {
  final MembershipService svc;
  MembersCubit(this.svc) : super(const MembersState());

  void setWarehouse(String warehouseId, {String? name, bool reload = true}) {
    emit(state.copyWith(warehouseId: warehouseId, warehouseName: name));
    if (reload) load();
  }

  Future<void> load() async {
    final wh = state.warehouseId;
    if (wh == null) {
      emit(state.copyWith(error: 'لم يتم تحديد مستودع'));
      return;
    }
    emit(state.copyWith(loading: true, error: null));
    try {
      final items = await svc.fetchMembers(wh);
      emit(state.copyWith(loading: false, items: items));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> addMember(String email) async {
    final wh = state.warehouseId!;
    await svc.addMemberByEmail(wh, email);
    await load();
  }

  Future<void> remove(String userId) async {
    final wh = state.warehouseId!;
    await svc.removeMember(wh, userId);
    await load();
  }

  Future<void> setLoginEnabled(String userId, bool enabled) async {
    await svc.setLoginEnabledByUserId(userId, enabled);
    await load();
  }
}