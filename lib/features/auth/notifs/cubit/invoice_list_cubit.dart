import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/invoice_audit_item.dart';
import '../services/invoice_audit_service.dart';

abstract class InvoiceListState {
  const InvoiceListState();
}
class InvoiceListInitial extends InvoiceListState { const InvoiceListInitial(); }
class InvoiceListLoading extends InvoiceListState { const InvoiceListLoading(); }
class InvoiceListLoaded extends InvoiceListState {
  final List<InvoiceAuditItem> invoices;
  const InvoiceListLoaded(this.invoices);
}
class InvoiceListError extends InvoiceListState {
  final String message;
  const InvoiceListError(this.message);
}

class InvoiceListCubit extends Cubit<InvoiceListState> {
  InvoiceListCubit(this._service, {required this.checked})
      : super(const InvoiceListInitial());

  final InvoiceAuditService _service;
  final bool checked;
  String? _warehouseId;

  void setWarehouse(String warehouseId, {bool reload = true}) {
    _warehouseId = warehouseId;
    if (reload) load();
  }

  Future<void> load() async {
    final wh = _warehouseId;
    if (wh == null) {
      emit(const InvoiceListError('لم يتم تحديد مستودع'));
      return;
    }
    emit(const InvoiceListLoading());
    try {
      final list = await _service.fetchInvoices(warehouseId: wh, checked: checked);
      emit(InvoiceListLoaded(list));
    } catch (e) {
      emit(InvoiceListError(e.toString()));
    }
  }

  Future<void> refresh() => load();

  Future<void> markChecked(String invoiceId) async {
    await _service.checkInvoice(invoiceId);
    await load(); // بعد التحقق، لو القائمة لغير مدققة رح يختفي منها
  }

  Future<void> markUnchecked(String invoiceId) async {
    await _service.uncheckInvoice(invoiceId);
    await load(); // بالعكس للقائمة المدققة
  }
}