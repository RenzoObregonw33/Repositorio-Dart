import 'package:flutter/material.dart';
import 'package:login/screens/dashboard_screen.dart';
import 'package:login/screens/detalle_diario_screen.dart'; // Eliminamos el 'hide'

class TabsDashboardScreen extends StatefulWidget {
  final String token;
  final int organiId;

  const TabsDashboardScreen({
    super.key,
    required this.token,
    required this.organiId,
  });

  @override
  State<TabsDashboardScreen> createState() => _TabsDashboardScreenState(); // Cambiado a _TabsDashboardScreenState
}

class _TabsDashboardScreenState extends State<TabsDashboardScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Contenido principal con margen inferior para los tabs
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 70), // Espacio para los tabs
              child: _currentTabIndex == 0
                  ? DashboardScreen(
                      token: widget.token,
                      organiId: widget.organiId,
                    )
                  : DetalleDiarioScreen(token: widget.token,
                      organiId: widget.organiId,),
            ),
          ),

          // Tabs en la parte inferior
          Positioned(
            bottom: 10, // Reducido de 20 a 10
            left: 20,    // Reducido de 30 a 20
            right: 20,   // Reducido de 30 a 20
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:  0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabCard(
                      'PANEL DE DESEMPEÑO',
                      0,
                      Icons.assessment_outlined,
                    ),
                  ),
                  const SizedBox(width: 8), // Reducido de 10 a 8
                  Expanded(
                    child: _buildTabCard(
                      'DETALLE DIARIO',
                      1,
                      Icons.calendar_today_outlined,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabCard(String text, int index, IconData icon) {
    final isSelected = _currentTabIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _currentTabIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF0F2747) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: Colors.grey.shade800, width: 1)
              : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 6), // Reducido de 8 a 6
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Color(0xFF0F2747),
              size: 18, // Reducido de 20 a 18
            ),
            const SizedBox(height: 2), // Reducido de 4 a 2
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
                fontSize: 11, // Reducido de 12 a 11
              ),
            ),
          ],
        ),
      ),
    );
  }
}