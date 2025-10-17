import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahaeng/features/auth/notifs/cubit/posted_state/PostedCubit.dart';
import 'package:tahaeng/features/utils/font_style.dart';
import '../../invoice/invoice_details_view.dart';
import '../cubit/notif_cubit.dart';
import '../cubit/notif_state.dart';

class NotifTab extends StatefulWidget {
  const NotifTab({super.key});

  @override
  State<NotifTab> createState() => _NotifTabState();
}

class _NotifTabState extends State<NotifTab> {
  final Set<String> _busy = {};

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

  Color _typeColor(String type) {
    switch (type) {
      case 'buy':
      case 'undoSell':
        return Colors.green.shade50;
      case 'sale':
      case 'undoBuy':
      case 'order':
        return Colors.orange.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  Future<void> _check(String invoiceId) async {
    setState(() => _busy.add(invoiceId));
    try {
      await context.read<NotifCubit>().checkInvoice(invoiceId);
      // نقل الفاتورة إلى "تم تدقيقها" بالتحديث
      try {
        await context.read<PostedCubit>().refresh();
      } catch (_) {}
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم التدقيق')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    } finally {
      if (mounted) setState(() => _busy.remove(invoiceId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotifCubit, NotifState>(
      builder: (context, state) {
        if (state is NotifLoading || state is NotifInitial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is NotifFailure) {
          return Center(child: Text('خطأ: ${state.message}'));
        }
        final groups = (state as NotifSuccess).groups;
        if (groups.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => context.read<NotifCubit>().refresh(),
            child: ListView(
              children: const [
                SizedBox(height: 200),
                Center(child: Text('لا توجد فواتير غير مدققة')),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<NotifCubit>().refresh(),
          child: SafeArea(
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: groups.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final g = groups[i];
                final isBusy = _busy.contains(g.invoiceId);
                final type = g.invoiceType ?? '';

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  color: _typeColor(type),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                _typeLabel(type),
                                style: FontStyleApp.appColor18,
                              ),
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              g.kind == 'new'
                                  ? 'فاتورة جديدة'
                                  : 'تم تعديل فاتورة',
                              style: FontStyleApp.appColor18,
                            ),
                            const Spacer(),
                            Text('#${g.invoiceId.substring(0, 8)}'),
                          ],
                        ),
                        const Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    style: FontStyleApp.appColor18,
                                    'الحساب: ${g.accountName ?? '-'}',
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    style: FontStyleApp.appColor18,
                                    'التاريخ: ${g.invoiceDate ?? '-'}',
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  style: FontStyleApp.appColor18,
                                  'النوع: ${_typeLabel(type)}',
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  style: FontStyleApp.appColor18,
                                  'تغييرات: ${g.count}',
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () async {
                                final moved = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => InvoiceDetailsView(
                                      invoiceId: g.invoiceId,
                                    ),
                                  ),
                                );
                                if (moved == true && mounted) {
                                  context.read<NotifCubit>().refresh();
                                  try {
                                    context.read<PostedCubit>().refresh();
                                  } catch (_) {}
                                }
                              },
                              child: const Text('تفاصيل'),
                            ),
                            Spacer(),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: isBusy
                                  ? null
                                  : () => _check(g.invoiceId),
                              icon: isBusy
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.verified),
                              label: const Text('تم التدقيق'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
