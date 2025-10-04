import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tahaeng/features/auth/notifs/cubit/posted_state/PostedCubit.dart';
import '../notifs/cubit/notif_cubit.dart';

import 'invoice_service.dart';

class InvoiceDetailsView extends StatefulWidget {
  final String invoiceId;
  const InvoiceDetailsView({super.key, required this.invoiceId});

  @override
  State<InvoiceDetailsView> createState() => _InvoiceDetailsViewState();
}

class _InvoiceDetailsViewState extends State<InvoiceDetailsView> {
  // ignore: unused_field
  final _df = DateFormat('yyyy-MM-dd');
  Map<String, dynamic>? d;
  bool _loading = true;
  String? _error;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final svc = AcctInvoiceService(Supabase.instance.client);
      final data = await svc.fetchInvoice(widget.invoiceId);
      setState(() => d = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  String fmtQty(num v) {
    final dv = v.toDouble();
    if (dv == dv.roundToDouble()) return dv.toStringAsFixed(0);
    return dv
        .toStringAsFixed(3)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  String typeLabel(String type) {
    switch (type) {
      case 'sale':
        return 'مبيع';
      case 'buy':
        return 'شراء';
      case 'undoSell':
        return 'مردود مبيع';
      case 'undoBuy':
        return 'مردود شراء';
      case 'order':
        return 'نقل';
      default:
        return type;
    }
  }

  Future<void> _checkInvoice() async {
    if (_checking) return;
    setState(() => _checking = true);
    try {
      await Supabase.instance.client.rpc(
        'fn_accountant_check_invoice',
        params: {'p_invoice_id': widget.invoiceId},
      );
      setState(() {
        if (d != null) d!['checked_by_accountant'] = true;
      });

      // حدّث تبويب "تم تدقيقها" + "غير مدققة"
      try {
        context.read<PostedCubit>().refresh();
      } catch (_) {}
      try {
        context.read<NotifCubit>().refresh();
      } catch (_) {}

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم التدقيق')));
      Navigator.pop(context, true); // رجوع مع إشارة للتحديث
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ أثناء التدقيق: $e')));
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = d;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الفاتورة'),
        actions: [
          if (!_loading && _error == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: _StatusChip(
                  checked: data?['checked_by_accountant'] == true,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('خطأ: $_error'))
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // كارد رأس الفاتورة
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // معلومات عامة
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    Chip(
                                      label: Text(
                                        typeLabel(
                                          (data!['type'] ?? '').toString(),
                                        ),
                                      ),
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    Chip(
                                      label: Text(
                                        '#${(data['id'] as String).substring(0, 8)}',
                                      ),
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('التاريخ: ${data['date'] ?? '-'}'),
                                Text(
                                  'الحساب: ${data['accounts']?['name'] ?? '-'}',
                                ),
                              ],
                            ),
                          ),

                          // زر "تم التدقيق"
                          if (data['checked_by_accountant'] != true)
                            ElevatedButton.icon(
                              onPressed: _checking ? null : _checkInvoice,
                              icon: _checking
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.verified),
                              label: const Text('تم التدقيق'),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // كارد ملاحظات (إن وجدت)
                  if ((data['notes'] ?? '').toString().trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.sticky_note_2_outlined,
                              color: Colors.teal,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                (data['notes'] ?? '').toString(),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  // بطاقات الأصناف (اسم المادة + كود المحاسبة + الوحدة + الكمية)
                  Expanded(
                    child: _ItemsCards(
                      items: (data['invoice_items'] as List?) ?? const [],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool checked;
  const _StatusChip({required this.checked});

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

class _ItemsCards extends StatelessWidget {
  final List items;
  const _ItemsCards({required this.items});

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

        return Card(
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
                  child: Text(
                    qty,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // اسم المادة + كود المحاسبة + الوحدة
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Chip(
                            label: Text('كود المحاسبة: $accCode'),
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'الوحدة: $unit',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
