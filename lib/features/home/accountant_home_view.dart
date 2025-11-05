import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// خدمات وإدارة الحالة
import 'package:tahaeng/features/auth/notifs/services/notification_service.dart';
import 'package:tahaeng/features/auth/notifs/cubit/notif_cubit.dart';
import 'package:tahaeng/features/auth/notifs/cubit/posted_state/PostedCubit.dart';

// الشاشات الفرعية (التبويبات)
import 'package:tahaeng/features/auth/notifs/views/notif_tab.dart';
import 'package:tahaeng/features/auth/notifs/views/posted_list_view.dart';

// شاشة اختيار المستودع + Cubit/Service الخاص بها
import 'package:tahaeng/features/auth/notifs/views/warehouse_picker_page.dart';
import 'package:tahaeng/features/auth/notifs/cubit/warehouse_picker_cubit.dart';
import 'package:tahaeng/features/auth/notifs/services/warehouse_service.dart';

class AccountantHomeView extends StatelessWidget {
  final String warehouseId;
  final String? warehouseName; // اختياري لعرض الاسم إن توفر
  const AccountantHomeView({
    super.key,
    required this.warehouseId,
    this.warehouseName,
  });

  // المهم هنا: لا نستعمل context داخل onSelected بعد pushReplacement
  // نلتقط NavigatorState قبل الانتقال ونستخدمه لاحقًا.
  Future<void> _openWarehousePicker(BuildContext context) async {
    final nav = Navigator.of(context); // التقط الـ Navigator مرة واحدة

    nav.pushReplacement(
      MaterialPageRoute(
        builder: (_) {
          return BlocProvider(
            create: (_) => WarehousePickerCubit(WarehouseService())..load(),
            child: Builder(
              builder: (pickerCtx) => WarehousePickerPage(
                onSelected: (whId) {
                  // نستخدم nav (المحفوظ) أو Navigator.of(pickerCtx) وليس context القديم
                  nav.pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => AccountantHomeView(warehouseId: whId),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sb = Supabase.instance.client;
    final notificationService = NotificationService(sb);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              NotifCubit(notificationService)..setWarehouse(warehouseId),
        ),
        BlocProvider(
          create: (_) =>
              PostedCubit(notificationService)..setWarehouse(warehouseId),
        ),
      ],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                tooltip: 'تبديل المستودع',
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _openWarehousePicker(context),
              ),
              title: Text(
                warehouseName == null
                    ? 'لوحة المحاسب'
                    : 'لوحة المحاسب • ${warehouseName!}',
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'غير مدققة'),
                  Tab(text: 'تم تدقيقها'),
                ],
              ),
            ),
            body: const TabBarView(
              children: [
                NotifTab(), // إشعارات/فواتير غير مدققة
                PostedListPage(), // فواتير مدققة
              ],
            ),
          ),
        ),
      ),
    );
  }
}
