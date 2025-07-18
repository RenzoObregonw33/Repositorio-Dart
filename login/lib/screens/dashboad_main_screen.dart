import 'package:flutter/material.dart';
import 'package:login/screens/dashboard_screen.dart';
import 'package:login/screens/detalle_screen.dart';

class DashboardMainScreen extends StatefulWidget {
  final int organiId;
  final String token;

  const DashboardMainScreen({
    super.key,
    required this.organiId,
    required this.token,
  });

  @override
  State<DashboardMainScreen> createState() => _DashboardMainScreenState();
}

class _DashboardMainScreenState extends State<DashboardMainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(
        organiId: widget.organiId,
        token: widget.token,
      ),
      const DetalleScreen(), // ← Puedes crear más pantallas aquí
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

 @override
  Widget build(BuildContext context) {

    return Scaffold(
      extendBody: true,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        color: Colors.transparent, // Fondo 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.bar_chart_rounded,
              label: 'Panel',
              index: 0,
              color: Colors.orange, // verde pastel
            ),
            _buildNavItem(
              icon: Icons.calendar_month_rounded,
              label: 'Detalle',
              index: 1,
              color: Colors.blue, // celeste pastel
            ),
          ],
        ),
      ),
    );
  }

    Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required Color color,
  }) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? color : Colors.black,),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
