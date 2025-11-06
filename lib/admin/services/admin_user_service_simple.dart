import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUserServiceSimple {
  final SupabaseClient _sb;
  AdminUserServiceSimple(this._sb);

  Future<String> createUserAndAssign({
    required String email,
    required String password,
    required String warehouseId,
    String? fullName,
  }) async {
    // 1) signUp
    final signUpRes = await _sb.auth.signUp(
      email: email,
      password: password,
      data: {
        if (fullName != null && fullName.trim().isNotEmpty) 'full_name': fullName.trim(),
      },
    );

    final newUserId = signUpRes.user?.id;
    if (newUserId == null) {
      throw Exception('فشل إنشاء الحساب (تأكد من إعدادات Auth/تأكيد البريد)');
    }

    // 2) انتظر مزامنة public.users (تريغر)
    for (int i = 0; i < 10; i++) {
      final row = await _sb.from('users').select('id').eq('id', newUserId).maybeSingle();
      if (row != null) break;
      await Future.delayed(const Duration(milliseconds: 200));
    }

    // 3) RPC: اسناد حصري للمستودع المطلوب
    await _sb.rpc('assign_user_to_warehouse_strict', params: {
      'p_email': email,
      'p_warehouse_id': warehouseId,
    });

    // 4) تسجيل خروج احترازي من جلسة هذا الحساب (لو وقعت)
    try { await _sb.auth.signOut(); } catch (_) {}

    return newUserId;
  }
}