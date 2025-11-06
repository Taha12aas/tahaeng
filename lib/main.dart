import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/supabase_env.dart';

// شاشة اختيار مستودع
import 'package:tahaeng/features/auth/notifs/views/warehouse_picker_page.dart';

// Cubit + Service لاختيار المستودع
import 'package:tahaeng/features/auth/notifs/cubit/warehouse_picker_cubit.dart';
import 'package:tahaeng/features/auth/notifs/services/warehouse_service.dart';

// الصفحة الرئيسية (تبويبان: غير مدققة/مدققة)
import 'features/home/accountant_home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: SupaEnv.url, anonKey: SupaEnv.anonKey);
  runApp(const AccountantApp());
}

class AccountantApp extends StatelessWidget {
  const AccountantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'لوحة المحاسب',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (_) => WarehousePickerCubit(WarehouseService())..load(),
        child: Builder(
          builder: (ctx) => WarehousePickerPage(
            onSelected: (warehouseId) {
              
              Navigator.of(ctx).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => AccountantHomeView(warehouseId: warehouseId),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}