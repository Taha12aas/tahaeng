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
        // ignore: deprecated_member_use
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

        final name = (med?['name'] ?? '-').toString();
        final unit = (med?['unit'] ?? '-').toString();
        final accCode = (med?['internal_code'] ?? '').toString();
        final qty = fmtQty((it['quantity'] as num?) ?? 0);

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // الكمية بحبة واضحة
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

                  // الاسم + الوحدة + كود المحاسبة
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // سطر الاسم + الوحدة
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // اسم المادة (يتقص تلقائياً لو طويل)
                            Expanded(
                              child: Tooltip(
                                message: name,
                                waitDuration: const Duration(milliseconds: 300),
                                child: Text(
                                  name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                  style: FontStyleApp.appColor18.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // شارة الوحدة
                            _unitPill(unit),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // كود المحاسبة داخل صندوق صغير قابل للاقتصاص
                        Align(
                          alignment: Alignment.centerRight,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 260, // حد أقصى للعرض حتى ما يكسر السطر
                            ),
                            child: _tagBox(
                              text: accCode.isEmpty
                                  ? 'كود المحاسبة: -'
                                  : 'كود المحاسبة: $accCode',
                            ),
                          ),
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

  Widget _unitPill(String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        unit.isEmpty ? '-' : unit,
        style: const TextStyle(fontSize: 12.5, color: Colors.black87),
      ),
    );
  }

  Widget _tagBox({required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12.5, color: Colors.black87),
      ),
    );
  }
}
