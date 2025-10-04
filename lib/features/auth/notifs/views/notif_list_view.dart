import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../invoice/invoice_details_view.dart';
import '../cubit/notif_cubit.dart';
import '../cubit/notif_state.dart';
import '../services/notification_service.dart';

class NotifListView extends StatelessWidget {
  const NotifListView({super.key});

  String _kindLabel(String kind) => kind == 'new' ? 'فاتورة جديدة' : 'تم تعديل فاتورة';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotifCubit(NotificationService(Supabase.instance.client))..load(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('إشعارات المحاسب'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<NotifCubit>().refresh(),
                tooltip: 'تحديث',
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await Supabase.instance.client.auth.signOut();
                },
                tooltip: 'تسجيل الخروج',
              ),
            ],
          ),
          body: BlocBuilder<NotifCubit, NotifState>(
            builder: (context, state) {
              if (state is NotifLoading || state is NotifInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is NotifFailure) {
                return Center(child: Text('خطأ: ${state.message}'));
              }
              final groups = (state as NotifSuccess).groups;
              if (groups.isEmpty) {
                return const Center(child: Text('لا توجد إشعارات'));
              }

              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: groups.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final g = groups[i];
                  final color = g.kind == 'new' ? Colors.green.shade50 : Colors.orange.shade50;

                  return Card(
                    color: color,
                    child: ListTile(
                      title: Text(_kindLabel(g.kind)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('الحساب: ${g.accountName ?? '-'}'),
                          Text('التاريخ: ${g.invoiceDate ?? '-'} | النوع: ${g.invoiceType ?? '-'}'),
                          Text('عدد التغييرات: ${g.count}'),
                        ],
                      ),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => InvoiceDetailsView(invoiceId: g.invoiceId),
                                ),
                              );
                            },
                            child: const Text('فتح'),
                          ),
                          ElevatedButton(
                            onPressed: () => context.read<NotifCubit>().checkInvoice(g.invoiceId),
                            child: const Text('تم التدقيق'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}