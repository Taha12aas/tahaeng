import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:tahaeng/admin/services/admin_user_service_simple.dart';
import '../../admin/models/warehouse.dart';
import '../../admin/cubits/members_cubit.dart';
import '../../admin/cubits/members_state.dart';
import '../../admin/services/membership_service.dart';

class WarehouseMembersPage extends StatelessWidget {
  final Warehouse warehouse;
  const WarehouseMembersPage({super.key, required this.warehouse});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MembersCubit(MembershipService(Supabase.instance.client))
            ..setWarehouse(warehouse.id, name: warehouse.name),
      child: _MembersView(warehouse: warehouse),
    );
  }
}

class _MembersView extends StatefulWidget {
  final Warehouse warehouse;
  const _MembersView({required this.warehouse});

  @override
  State<_MembersView> createState() => _MembersViewState();
}

class _MembersViewState extends State<_MembersView> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  // حالة الانشغال لكل مستخدم أثناء التبديل
  final Set<String> _busy = <String>{};

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleLoginEnabled({
    required String userId,
    required bool target,
    required String emailForMsg,
  }) async {
    if (_busy.contains(userId)) return;
    final messenger = ScaffoldMessenger.of(context);
    final membersCubit = context.read<MembersCubit>();

    setState(() {
      _busy.add(userId);
    });

    try {
      await membersCubit.setLoginEnabled(userId, target);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            target
                ? 'تم تفعيل الدخول ($emailForMsg)'
                : 'تم إيقاف الدخول ($emailForMsg)',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('فشل التغيير: $e')));
    } finally {
      if (!mounted) return;
      setState(() {
        _busy.remove(userId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MembersCubit>();

    return Scaffold(
      appBar: AppBar(
        title: Text('أعضاء: ${widget.warehouse.name}'),
        actions: [
          IconButton(onPressed: cubit.load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: BlocBuilder<MembersCubit, MembersState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(child: Text('خطأ: ${state.error}'));
          }

          return Column(
            children: [
              // إضافة سريعة: بريد + كلمة مرور -> إنشاء حساب وإسناده مباشرة
              Padding(
                padding: const EdgeInsets.all(12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 700;

                    final emailField = TextField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        hintText: 'name@email.com',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    );

                    final passwordField = TextField(
                      controller: _passwordCtrl,
                      decoration: const InputDecoration(
                        labelText: 'كلمة المرور',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    );

                    final addBtn = SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final email = _emailCtrl.text.trim();
                          final password = _passwordCtrl.text.trim();
                          if (email.isEmpty || password.isEmpty) return;

                          final messenger = ScaffoldMessenger.of(context);
                          final membersCubit = context.read<MembersCubit>();
                          final whId = membersCubit.state.warehouseId!;

                          try {
                            final adminSvc = AdminUserServiceSimple(
                              Supabase.instance.client,
                            );
                            await adminSvc.createUserAndAssign(
                              email: email,
                              password: password,
                              warehouseId: whId,
                              fullName: null,
                            );
                            await membersCubit.load();
                            if (!mounted) return;
                            _emailCtrl.clear();
                            _passwordCtrl.clear();
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'تم إنشاء الحساب وإسناده للمستودع',
                                ),
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(content: Text('خطأ: $e')),
                            );
                          }
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('إضافة'),
                      ),
                    );

                    if (isNarrow) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          emailField,
                          const SizedBox(height: 8),
                          passwordField,
                          const SizedBox(height: 8),
                          addBtn,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(flex: 2, child: emailField),
                        const SizedBox(width: 8),
                        Expanded(flex: 2, child: passwordField),
                        const SizedBox(width: 8),
                        addBtn,
                      ],
                    );
                  },
                ),
              ),

              const Divider(height: 1),

              // قائمة الأعضاء + مفتاح تفعيل/إيقاف الدخول (بدون StatefulBuilder)
              Expanded(
                child: ListView.separated(
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final m = state.items[i];
                    final isBusy = _busy.contains(m.userId);

                    return ListTile(
                      title: Text(
                        m.fullName.isNotEmpty ? m.fullName : m.email,
                        style: TextStyle(
                          color: m.loginEnabled ? null : Colors.grey.shade600,
                          fontStyle: m.loginEnabled
                              ? FontStyle.normal
                              : FontStyle.italic,
                        ),
                      ),
                      subtitle: Text(m.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isBusy)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          if (isBusy) const SizedBox(width: 8),
                          Text(m.loginEnabled ? 'مفعّل' : 'موقوف'),
                          const SizedBox(width: 8),
                          Switch(
                            value: m.loginEnabled,
                            onChanged: isBusy
                                ? null
                                : (val) => _toggleLoginEnabled(
                                    userId: m.userId,
                                    target: val,
                                    emailForMsg: m.email,
                                  ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
