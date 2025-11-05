import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tahaeng/features/auth/notifs/cubit/posted_state/PostedCubit.dart';
import 'package:tahaeng/features/auth/notifs/widgets/items_cards.dart';
import 'package:tahaeng/features/auth/notifs/widgets/status_chip.dart';
import 'package:tahaeng/features/utils/const.dart';
import 'package:tahaeng/features/utils/font_style.dart';
import '../notifs/cubit/notif_cubit.dart';

import '../notifs/services/notification_service.dart';
import 'invoice_service.dart';

class InvoiceDetailsView extends StatefulWidget {
  final String invoiceId;
  const InvoiceDetailsView({super.key, required this.invoiceId});

  @override
  State<InvoiceDetailsView> createState() => _InvoiceDetailsViewState();
}

class _InvoiceDetailsViewState extends State<InvoiceDetailsView> {
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
      if (mounted) setState(() => _loading = false);
    }
  }

  String _typeLabel(String type) {
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

  String _dateLabel(dynamic v) {
    if (v == null) return '-';
    if (v is DateTime) return _df.format(v);
    final s = v.toString();
    final dt = DateTime.tryParse(s);
    return dt != null ? _df.format(dt) : s;
  }

  String _creatorName(Map<String, dynamic>? data) {
    final u = (data?['users'] as Map?)?.cast<String, dynamic>();
    final name = (u?['full_name'] as String?)?.trim();
    final email = (u?['email'] as String?)?.trim();
    if (name != null && name.isNotEmpty) return name;
    if (email != null && email.isNotEmpty) return email!;
    return '-';
  }

  Future<void> _checkInvoice() async {
    if (_checking) return;
    setState(() => _checking = true);

    // خزّن المراجع قبل await
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final postedCubit = context.read<PostedCubit?>();
    final notifCubit = context.read<NotifCubit?>();

    try {
      await NotificationService(
        Supabase.instance.client,
      ).markChecked(widget.invoiceId);

      if (mounted) {
        setState(() {
          if (d != null) d!['checked_by_accountant'] = true;
        });
      }

      await postedCubit?.refresh();
      await notifCubit?.refresh();

      messenger.showSnackBar(const SnackBar(content: Text('تم التدقيق')));
      navigator.pop(true);
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('خطأ أثناء التدقيق: $e')),
        );
      }
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
                child: StatusChip(
                  checked: data?['checked_by_accountant'] == true,
                  compact: true,
                  tooltip: (data?['checked_by_accountant'] == true)
                      ? 'مدقّقة'
                      : 'بانتظار التدقيق',
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('خطأ: $_error', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
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
                          if (data?['checked_by_accountant'] != true)
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
                              label: const Text(
                                'تم التدقيق',
                                style: FontStyleApp.appColor18,
                              ),
                            ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    Chip(
                                      label: Text(
                                        _typeLabel(
                                          (data?['type'] ?? '').toString(),
                                        ),
                                        style: FontStyleApp.appColor18,
                                      ),
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'التاريخ: ${_dateLabel(data?['date'])}',
                                  style: FontStyleApp.black18,
                                ),
                                const SizedBox(height: 5),
                                FittedBox(
                                  child: Text(
                                    'الحساب: ${data?['accounts']?['name'] ?? '-'}',
                                    style: FontStyleApp.black18,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                FittedBox(
                                  child: Text(
                                    'أضيفت بواسطة: ${_creatorName(data)}',
                                    style: FontStyleApp.black18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (((data?['notes'] ?? '').toString().trim())
                      .isNotEmpty) ...[
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
                          children: [
                            Expanded(
                              child: Text(
                                (data?['notes'] ?? '').toString(),
                                textAlign: TextAlign.right,
                                style: FontStyleApp.appColor18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.sticky_note_2_outlined,
                              color: kAppColor,
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  Expanded(
                    child: ItemsCards(
                      items: (data?['invoice_items'] as List?) ?? const [],
                      dense: false,
                      showIndex: true,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
