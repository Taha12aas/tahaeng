import 'package:tahaeng/features/auth/notifs/models/posted_invoice.dart';

abstract class PostedState {}

class PostedInitial extends PostedState {}

class PostedLoading extends PostedState {}

class PostedLoaded extends PostedState {
  final List<PostedInvoice> items;
  final bool hasMore;
  final bool isLoadingMore;
  PostedLoaded({
    required this.items,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  PostedLoaded copyWith({
    List<PostedInvoice>? items,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PostedLoaded(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class PostedFailure extends PostedState {
  final String message;
  PostedFailure(this.message);
}