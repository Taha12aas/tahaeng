import '../models/notif_group.dart';

abstract class NotifState {}
class NotifInitial extends NotifState {}
class NotifLoading extends NotifState {}
class NotifFailure extends NotifState {
  final String message;
  NotifFailure(this.message);
}
class NotifSuccess extends NotifState {
  final List<NotifGroup> groups;
  NotifSuccess(this.groups);
}