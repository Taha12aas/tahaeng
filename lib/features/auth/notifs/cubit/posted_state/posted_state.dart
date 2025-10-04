import 'package:tahaeng/features/auth/notifs/models/posted_invoice.dart';

abstract class PostedState {}
class PostedInitial extends PostedState {}
class PostedLoading extends PostedState {}
class PostedFailure extends PostedState {
  final String message;
  PostedFailure(this.message);
}
class PostedSuccess extends PostedState {
  final List<PostedInvoice> items;
  PostedSuccess(this.items);
}