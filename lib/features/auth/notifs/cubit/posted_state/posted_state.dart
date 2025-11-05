abstract class PostedState {
  const PostedState();
}
class PostedLoading extends PostedState { const PostedLoading(); }
class PostedFailure extends PostedState {
  final String message;
  const PostedFailure(this.message);
}
class PostedLoaded extends PostedState {
  final List<Map<String, dynamic>> items;
  final bool hasMore;
  final bool isLoadingMore;
  const PostedLoaded({required this.items, required this.hasMore, this.isLoadingMore=false});

  PostedLoaded copyWith({List<Map<String, dynamic>>? items, bool? hasMore, bool? isLoadingMore}) {
    return PostedLoaded(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}