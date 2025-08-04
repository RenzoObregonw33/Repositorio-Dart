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
          backgroundColor: Color(0xFFFBB347), 
          foregroundColor: Colors.black, // Texto negro
          elevation: 1, // Sombra sutil
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Colors.grey, // Borde gris claro
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onPressed: () => _selectDateRange(context),
        child: Text(
          range == null
              ? 'Seleccionar rango de fechas'
              : '${_formatDate(range.start)} - ${_formatDate(range.end)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: range,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // Color del header
              onPrimary: Colors.white, // Texto del header
              onSurface: Colors.white, // Texto de las fechas
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // Botones de cancelar/ok
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    onRangeSelected(picked);
  }
}