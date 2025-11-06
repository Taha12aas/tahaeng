import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../admin/cubits/warehouses_cubit.dart';
import '../../admin/cubits/warehouses_state.dart';
import '../../admin/services/warehouse_service.dart';
import '../../admin/models/warehouse.dart';
import '../../admin/views/warehouse_members_page.dart';

class WarehouseListPage extends StatelessWidget {
  const WarehouseListPage({super.key});

  Future<void> _renameDialog(BuildContext ctx, Warehouse w) async {
    final ctrl = TextEditingController(text: w.name);
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('إعادة تسمية'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'اسم جديد'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    if (ok == true && ctrl.text.trim().isNotEmpty) {
      await ctx.read<WarehousesCubit>().rename(w.id, ctrl.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          WarehousesCubit(WarehouseService(Supabase.instance.client))..load(),
      // Builder مهم حتى نأخذ context تحته الـ Provider
      child: Builder(
        builder: (ctx) => Scaffold(
          appBar: AppBar(
            title: const Text('إدارة المستودعات'),
            actions: [
              IconButton(
                onPressed: () => ctx.read<WarehousesCubit>().load(),
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          body: BlocBuilder<WarehousesCubit, WarehousesState>(
            // ملاحظة: هنا نستخدم ctx أيضًا، لكن BlocBuilder يوفّر سياق تحت الـ Provider
            builder: (ctx, state) {
              if (state.loading) {
                return Center(child: CircularProgressIndicator());
              }
              if (state.error != null) {
                return Center(child: Text('خطأ: ${state.error}'));
              }
              if (state.items.isEmpty) {
                return const Center(
                  child: Text('لا توجد مستودعات. اضغط + للإضافة.'),
                );
              }
              return ListView.separated(
                itemCount: state.items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final w = state.items[i];
                  return ListTile(
                    title: Text(w.name),
                    subtitle: Text(
                      w.createdAt?.toLocal().toString().split('.').first ?? '',
                    ),
                    onTap: () {
                      Navigator.of(ctx).push(
                        MaterialPageRoute(
                          builder: (_) => WarehouseMembersPage(warehouse: w),
                        ),
                      );
                    },
                    trailing: Wrap(
                      spacing: 6,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    WarehouseMembersPage(warehouse: w),
                              ),
                            );
                          },
                          child: const Text('الأعضاء'),
                        ),
                        IconButton(
                          onPressed: () => _renameDialog(ctx, w),
                          icon: const Icon(Icons.edit),
                        ),
                      ],
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
