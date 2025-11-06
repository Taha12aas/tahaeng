class Warehouse {
  final String id;
  final String name;
  final DateTime? createdAt;

  Warehouse({required this.id, required this.name, this.createdAt});

  factory Warehouse.fromMap(Map<String, dynamic> m) => Warehouse(
        id: m['id'] as String,
        name: m['name'] as String,
        createdAt: m['created_at'] != null ? DateTime.parse(m['created_at']) : null,
      );
}