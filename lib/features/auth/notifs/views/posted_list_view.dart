import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
  final _df = DateFormat('yyyy-MM-dd');

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
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
      initialDateRange: initialRange,
      helpText: 'اختر نطاق التاريخ',
      confirmText: 'تطبيق',
      cancelText: 'إلغاء',
    );

    if (range != null) {
      final start = DateTime(
        range.start.year,
        range.start.month,
        range.start.day,
      );
      final end = DateTime(range.end.year, range.end.month, range.end.day);
      await cubit.setDateRange(start, end);
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'sale':
        return 'مبيع';
      case 'buy':
        return 'شراء';
      case 'undoSell':
        return 'مردود مبيع';
      case 'undoBuy':
        return 'مردود شراء';
      case 'order':
        return 'نقل';
      default:
        return type;
    }
  }

  String _dateLabel(dynamic v) {
    if (v == null) return '-';
    if (v is DateTime) return _df.format(v);
    final s = v.toString();
    final dt = DateTime.tryParse(s);
    return dt != null ? _df.format(dt) : s;
  }

  String _creatorName(Map<String, dynamic> it) {
    final u = it['users'] as Map<String, dynamic>?;
    final name = (u?['full_name'] as String?)?.trim();
    final email = (u?['email'] as String?)?.trim();
    if (name != null && name.isNotEmpty) return name;
    if (email != null && email.isNotEmpty) return email;
    return '-';
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
            return RefreshIndicator(
              onRefresh: () => context.read<PostedCubit>().refresh(),
              child: ListView.builder(
                controller: _controller,
                itemCount: items.length + 1,
                itemBuilder: (context, index) {
                  if (index < items.length) {
                    final it = Map<String, dynamic>.from(items[index]);
                    return ListTile(
                      title: Text(
                        '${_typeLabel(it['type'])} • ${it['accounts']?['name'] ?? '-'}',
                      ),
                      subtitle: Text('أضيفت بواسطة: ${_creatorName(it)}'),
                      trailing: Text(_dateLabel(it['date'])),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                InvoiceDetailsView(invoiceId: it['id']),
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
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
