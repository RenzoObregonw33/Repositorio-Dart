import 'package:flutter/material.dart';

class SelectorFechaSimple extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const SelectorFechaSimple({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFA528), Color(0xFFF77B09)],
            stops: [0.1, 0.9],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              onDateSelected(picked);
            }
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today, size: 20, color: Colors.black),
              const SizedBox(width: 8),
              Text(
                "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}