import 'package:flutter/material.dart';

class SelectorFechas extends StatelessWidget {
  final DateTimeRange range;
  final Function(DateTimeRange?) onRangeSelected;

  const SelectorFechas({
    super.key,
    required this.range,
    required this.onRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
        onPressed: () => _selectDateRange(context),
        child: Text(
          range == null
              ? 'Seleccionar rango de fechas'
              : '${range!.start.day}/${range!.start.month} - ${range!.end.day}/${range!.end.month}',
        ),
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: range,
    );
    onRangeSelected(picked);
  }
}