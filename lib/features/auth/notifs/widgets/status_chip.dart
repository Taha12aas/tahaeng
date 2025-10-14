import 'package:flutter/material.dart';
import 'package:tahaeng/features/utils/font_style.dart';

class StatusChip extends StatelessWidget {
  final bool checked;
  const StatusChip({super.key, required this.checked});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        checked ? Icons.verified : Icons.hourglass_bottom,
        color: checked ? Colors.green : Colors.orange,
        size: 18,
      ),
      label: Text(
        checked ? 'مدقّقة' : 'بانتظار تدقيق',
        style: TextStyle(color: checked ? Colors.green : Colors.orange),
      ),
      backgroundColor: Colors.white,
      side: BorderSide(
        color: (checked ? Colors.green : Colors.orange).withOpacity(0.4),
      ),
    );
  }
}

class ItemsCards extends StatelessWidget {
  final List items;
  const ItemsCards({super.key, required this.items});

  String fmtQty(num v) {
    final dv = v.toDouble();
    if (dv == dv.roundToDouble()) return dv.toStringAsFixed(0);
    return dv
        .toStringAsFixed(3)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('لا توجد أصناف'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(4),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final it = items[i] as Map<String, dynamic>;
        final med = it['medicines'] as Map<String, dynamic>?;

        final name = med?['name'] ?? '-';
        final unit = med?['unit'] ?? '-';
        final accCode = med?['internal_code'] ?? '-';
        final qty = fmtQty(it['quantity'] as num);

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // الكمية بخط واضح
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(qty, style: FontStyleApp.appColor18),
                  ),
                  const SizedBox(width: 10),
                  // اسم المادة + كود المحاسبة + الوحدة
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(name, style: FontStyleApp.appColor18),
                            Spacer(),
                            Text(
                              'الوحدة: $unit',
                              style: FontStyleApp.appColor18,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Chip(
                              label: Text(
                                'كود المحاسبة: $accCode',
                                style: FontStyleApp.appColor18,
                              ),
                              backgroundColor: Colors.white,
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
