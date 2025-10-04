import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahaeng/features/auth/notifs/cubit/posted_state/PostedCubit.dart';
import 'package:tahaeng/features/auth/notifs/cubit/posted_state/posted_state.dart';

import '../../invoice/invoice_details_view.dart';

class PostedListView extends StatelessWidget {
  const PostedListView({super.key});

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostedCubit, PostedState>(
      builder: (context, state) {
        if (state is PostedLoading || state is PostedInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is PostedFailure) {
          return Center(child: Text('خطأ: ${state.message}'));
        }
        final items = (state as PostedSuccess).items;
        if (items.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => context.read<PostedCubit>().refresh(),
            child: ListView(
              children: const [
                SizedBox(height: 200),
                Center(child: Text('لا توجد فواتير مدقّقة')),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<PostedCubit>().refresh(),
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final inv = items[i];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: ListTile(
                  title: Text('التاريخ: ${inv.date}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الحساب: ${inv.accountName ?? '-'}'),
                      Text('النوع: ${_typeLabel(inv.type)}'),
                    ],
                  ),
                  trailing: TextButton(
                    onPressed: () async {
                      final moved = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => InvoiceDetailsView(invoiceId: inv.id),
                        ),
                      );
                      if (moved == true && context.mounted) {
                        context.read<PostedCubit>().refresh();
                        // ممكن تعمل refresh لتبويب غير مدققة إذا حاب:
                        // try { context.read<NotifCubit>().refresh(); } catch (_) {}
                      }
                    },
                    child: const Text('تفاصيل'),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
