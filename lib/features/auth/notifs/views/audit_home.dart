import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahaeng/features/auth/notifs/cubit/notif_cubit.dart';
import 'package:tahaeng/features/auth/notifs/cubit/posted_state/PostedCubit.dart';
import 'package:tahaeng/features/auth/notifs/views/notif_tab.dart';
import 'package:tahaeng/features/auth/notifs/views/posted_list_view.dart';
import '../services/notification_service.dart';  
import 'package:supabase_flutter/supabase_flutter.dart';
 

class AuditHome extends StatelessWidget {
  final String warehouseId;
  const AuditHome({super.key, required this.warehouseId});

  @override
  Widget build(BuildContext context) {
    final sb = Supabase.instance.client;
    final notificationService = NotificationService(sb);

    return DefaultTabController(
      length: 2,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => NotifCubit(notificationService)..setWarehouse(warehouseId)),
          BlocProvider(create: (_) => PostedCubit(notificationService)..setWarehouse(warehouseId)),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: const Text('تدقيق الفواتير'),
            bottom: const TabBar(tabs: [
              Tab(text: 'غير مُدقَّقة'),
              Tab(text: 'مُدقَّقة'),
            ]),
          ),
          body: const TabBarView(children: [
            NotifTab(),       // القائمة غير المدققة (إشعارات)
            PostedListPage(), // القائمة المدققة
          ]),
        ),
      ),
    );
  }
}