import '../models/notif_group.dart';

abstract class NotifState {
  const NotifState();
}
class NotifInitial extends NotifState { const NotifInitial(); }
class NotifLoading extends NotifState { const NotifLoading(); }
class NotifSuccess extends NotifState {
  final List<NotifGroup> groups;
  const NotifSuccess(this.groups);
}
class NotifFailure extends NotifState {
  final String message;
  const NotifFailure(this.message);
}