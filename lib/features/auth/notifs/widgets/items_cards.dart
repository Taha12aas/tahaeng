import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tahaeng/features/utils/font_style.dart';

class ItemsCards extends StatelessWidget {
  final List items;
  final bool dense;         // جديد: مظهر مضغوط
  final bool showIndex;     // جديد: عرض الرقم التسلسلي
  const ItemsCards({
    super.key,
    required this.items,
    this.dense = false,
    this.showIndex = true,
  });

  String _fmtQty(num v) {
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
      separatorBuilder: (_, __) => SizedBox(height: dense ? 6 : 8),
      itemBuilder: (_, i) {
        final it = (items[i] as Map).cast<String, dynamic>();
        final med = (it['medicines'] as Map?)?.cast<String, dynamic>();

        final name   = (med?['name'] ?? '-').toString();
        final unit   = (med?['unit'] ?? '-').toString();
        final code   = (med?['internal_code'] ?? '').toString();
        final barcode= (med?['barcode'] ?? '').toString();
        final qtyNum = (it['quantity'] is num)
            ? (it['quantity'] as num)
            : num.tryParse((it['quantity'] ?? '0').toString()) ?? 0;
        final qty    = _fmtQty(qtyNum);

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Card(
            elevation: dense ? 1 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: dense ? 10 : 12,
                vertical: dense ? 8 : 10,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // الكمية (كبيرة وواضحة)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: dense ? 10 : 12,
                      vertical: dense ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      qty,
                      style: FontStyleApp.appColor18.copyWith(
                        fontSize: dense ? 15 : 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // الاسم + الوحدة + أكواد
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // السطر الأول: رقم + اسم + وحدة
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (showIndex)
                              Padding(
                                padding: const EdgeInsetsDirectional.only(end: 6.0),
                                child: Text(
                                  '#${i + 1}',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: dense ? 12 : 13,
                                  ),
                                ),
                              ),
                            // الاسم
                            Expanded(
                              child: Tooltip(
                                message: name,
                                waitDuration: const Duration(milliseconds: 250),
                                child: Text(
                                  name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                  style: FontStyleApp.appColor18.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: dense ? 15 : 17,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // شارة الوحدة
                            _pill(unit.isEmpty ? '-' : unit),
                          ],
                        ),

                        SizedBox(height: dense ? 4 : 6),

                        // صف أكواد (كود المحاسبة + الباركود إذا وجد)
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _tagBox(
                              text: code.isEmpty ? 'كود المحاسبة: -' : 'كود المحاسبة: $code',
                              onCopy: code.isEmpty ? null : () => _copy(context, code, 'تم نسخ كود المحاسبة'),
                            ),
                            if (barcode.isNotEmpty)
                              _tagBox(
                                text: 'الباركود: $barcode',
                                onCopy: () => _copy(context, barcode, 'تم نسخ الباركود'),
                              ),
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

  Widget _pill(String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        unit,
        style: const TextStyle(fontSize: 12.5, color: Colors.black87),
      ),
    );
  }

  Widget _tagBox({required String text, VoidCallback? onCopy}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5, color: Colors.black87),
            ),
          ),
          if (onCopy != null) ...[
            const SizedBox(width: 6),
            InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: onCopy,
              child: const Icon(Icons.copy, size: 16, color: Colors.black54),
            ),
          ],
        ],
      ),
    );
  }

  void _copy(BuildContext context, String value, String toast) async {
    await Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(toast), behavior: SnackBarBehavior.floating, duration: const Duration(milliseconds: 900)),
    );
  }
}