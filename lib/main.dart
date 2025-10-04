import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/supabase_env.dart';
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
      home: const AccountantHomeView(),
    );
  }
}