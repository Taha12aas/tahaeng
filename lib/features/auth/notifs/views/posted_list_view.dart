import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahaeng/features/auth/invoice/invoice_details_view.dart';
import 'package:tahaeng/features/auth/notifs/cubit/posted_state/PostedCubit.dart';
import 'package:tahaeng/features/auth/notifs/cubit/posted_state/posted_state.dart';

class PostedListPage extends StatefulWidget {
  const PostedListPage({super.key});

  @override
  State<PostedListPage> createState() => _PostedListPageState();
}

class _PostedListPageState extends State<PostedListPage> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<PostedCubit>().load();
    _controller.addListener(() {
      final max = _controller.position.maxScrollExtent;
      final pos = _controller.position.pixels;
      if (pos >= max - 200) {
        context.read<PostedCubit>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickRange() async {
    final cubit = context.read<PostedCubit>();
    final initialRange = (cubit.fromDate != null && cubit.toDate != null)
        ? DateTimeRange(start: cubit.fromDate!, end: cubit.toDate!)
        : null;

    final now = DateTime.now();
    final firstDate = DateTime(now.year - 2);
    final lastDate = DateTime(now.year + 2);

    final range = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: initialRange,
      helpText: 'اختر نطاق التاريخ',
      confirmText: 'تطبيق',
      cancelText: 'إلغاء',
    );

    if (range != null) {
      // ننظّف الوقت (نخليه تواريخ فقط)
      final start = DateTime(
        range.start.year,
        range.start.month,
        range.start.day,
      );
      final end = DateTime(range.end.year, range.end.month, range.end.day);
      await cubit.setDateRange(start, end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<PostedCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الفواتير المدقّقة'),
        actions: [
          if (cubit.fromDate != null || cubit.toDate != null)
            IconButton(
              tooltip: 'مسح الفلتر',
              icon: const Icon(Icons.filter_alt_off),
              onPressed: () => cubit.clearDateRange(),
            ),
          IconButton(
            tooltip: 'فلترة بالتاريخ',
            icon: const Icon(Icons.filter_alt),
            onPressed: _pickRange,
          ),
        ],
      ),
      body: BlocBuilder<PostedCubit, PostedState>(
        builder: (context, state) {
          if (state is PostedLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PostedFailure) {
            return Center(child: Text('خطأ: ${state.message}'));
          }
          if (state is PostedLoaded) {
            final items = state.items;
            return Column(
              children: [
                // شريحة تبين الفلتر الحالي (إن وُجد)
                if (cubit.fromDate != null || cubit.toDate != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Wrap(
                      children: [
                        Chip(
                          label: Text(
                            _rangeLabel(cubit.fromDate, cubit.toDate),
                          ),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () => cubit.clearDateRange(),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<PostedCubit>().refresh(),
                    child: ListView.builder(
                      controller: _controller,
                      itemCount: items.length + 1,
                      itemBuilder: (context, index) {
                        if (index < items.length) {
                          final it = items[index];
                          return ListTile(
                            title: Text(
                              '${it.type} • ${it.accountName ?? '-'}',
                            ),

                            trailing: Text(
                              it.date,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.indigo,
                              ),
                            ),
                            onTap: () async {
                              final inv = it;
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      InvoiceDetailsView(invoiceId: inv.id),
                                ),
                              );
                            },
                          );
                        }

                        if (state.isLoadingMore) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (!state.hasMore) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(child: Text('لا مزيد من النتائج')),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _dateOnly(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  String _rangeLabel(DateTime? from, DateTime? to) {
    String fmt(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    if (from != null && to != null) return 'من ${fmt(from)} إلى ${fmt(to)}';
    if (from != null) return 'من ${fmt(from)}';
    if (to != null) return 'إلى ${fmt(to)}';
    return '';
  }
}
