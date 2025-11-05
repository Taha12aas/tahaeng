import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final bool checked;
  final bool compact;            // جديد: شريحة مضغوطة
  final String? tooltip;         // جديد: تلميح عند الوقوف
  final VoidCallback? onTap;     // جديد: فعل عند الضغط

  const StatusChip({
    super.key,
    required this.checked,
    this.compact = false,
    this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = checked ? Colors.green : Colors.orange;
    final String label = checked ? 'مدقّقة' : 'بانتظار تدقيق';

    final chip = InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Chip(
        avatar: Icon(
          checked ? Icons.verified : Icons.hourglass_bottom,
          color: color,
          size: compact ? 16 : 18,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: compact ? 12.5 : 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        side: BorderSide(color: color.withOpacity(0.35)),
        visualDensity: compact ? VisualDensity.compact : VisualDensity.standard,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );

    return tooltip != null ? Tooltip(message: tooltip!, child: chip) : chip;
  }
}