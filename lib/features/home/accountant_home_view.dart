import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tahaeng/features/auth/notifs/cubit/notif_cubit.dart';
import 'package:tahaeng/features/auth/notifs/cubit/posted_state/PostedCubit.dart';
import 'package:tahaeng/features/auth/notifs/services/notification_service.dart';
import 'package:tahaeng/features/auth/notifs/views/notif_tab.dart';
import 'package:tahaeng/features/auth/notifs/services/posted_service.dart';
import 'package:tahaeng/features/auth/notifs/views/posted_list_view.dart';

class AccountantHomeView extends StatelessWidget {
  const AccountantHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final sb = Supabase.instance.client;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => NotifCubit(NotificationService(sb))..load(),
        ),
        BlocProvider(
          create: (context) => PostedCubit(PostedService(sb))..load(),
        ),
      ],
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('لوحة المحاسب'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'غير مدققة'),
                  Tab(text: 'تم تدقيقها'),
                ],
              ),
            ),
            body: const TabBarView(children: [NotifTab(), PostedListView()]),
          ),
        ),
      ),
    );
  }
}
