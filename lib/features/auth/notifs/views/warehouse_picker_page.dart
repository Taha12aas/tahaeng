import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tahaeng/features/auth/notifs/cubit/warehouse_picker_cubit.dart'; 

class WarehousePickerPage extends StatefulWidget {
  final void Function(String warehouseId) onSelected;
  const WarehousePickerPage({super.key, required this.onSelected});

  @override
  State<WarehousePickerPage> createState() => _WarehousePickerPageState();
}

class _WarehousePickerPageState extends State<WarehousePickerPage> {
  @override
  void initState() {
    super.initState();
    context.read<WarehousePickerCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختيار مستودع')),
      body: BlocBuilder<WarehousePickerCubit, WarehousePickerState>(
        builder: (context, state) {
          if (state.loading) return const Center(child: CircularProgressIndicator());
          if (state.error != null) return Center(child: Text('خطأ: ${state.error}'));
          if (state.warehouses.isEmpty) return const Center(child: Text('لا يوجد مستودعات'));

          return ListView.separated(
            itemCount: state.warehouses.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final w = state.warehouses[i];
              final selected = state.selectedId == w.id;
              return ListTile(
                title: Text(w.name),
                trailing: selected ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  context.read<WarehousePickerCubit>().select(w.id);
                  widget.onSelected(w.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}