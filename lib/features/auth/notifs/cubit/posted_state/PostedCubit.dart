import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahaeng/features/auth/notifs/services/posted_service.dart';
import 'posted_state.dart';

class PostedCubit extends Cubit<PostedState> {
  final PostedService service;
  PostedCubit(this.service) : super(PostedInitial());

  Future<void> load() async {
    emit(PostedLoading());
    try {
      final items = await service.fetchPostedAll();
      emit(PostedSuccess(items));
    } catch (e) {
      emit(PostedFailure(e.toString()));
    }
  }

  Future<void> refresh() async {
    try {
      final items = await service.fetchPostedAll();
      emit(PostedSuccess(items));
    } catch (e) {
      emit(PostedFailure(e.toString()));
    }
  }
}