// lib/admin/models/warehouse_member.dart
class WarehouseMember {
  final String userId;
  final String email;
  final String fullName;
  final String role;
  final bool loginEnabled; // جديد
  final DateTime? createdAt;

  WarehouseMember({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
    required this.loginEnabled,
    this.createdAt,
  });

  factory WarehouseMember.fromMap(Map<String, dynamic> row) {
    final u = (row['users'] as Map?)?.cast<String, dynamic>() ?? {};
    return WarehouseMember(
      userId: (row['user_id'] ?? u['id']).toString(),
      email: (u['email'] ?? '').toString(),
      fullName: (u['full_name'] ?? '').toString(),
      role: (row['role'] ?? '').toString(),
      loginEnabled: (u['login_enabled'] as bool?) ?? true, // افتراضيًا مفعل
      createdAt: row['created_at'] != null ? DateTime.parse(row['created_at']) : null,
    );
  }
}