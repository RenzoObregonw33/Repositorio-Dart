import 'package:flutter/material.dart';
import 'package:login/Models/filtro_data.dart';
import 'package:login/Apis/api_graphics_services.dart';

class SelectorFiltros extends StatefulWidget {
  final ApiGraphicsService graphicsService;
  final Function(List<GrupoFiltros>) onFiltrosChanged;
  final VoidCallback? onClose;

  const SelectorFiltros({
    super.key,
    required this.graphicsService,
    required this.onFiltrosChanged,
    this.onClose,
  });

  @override
  State<SelectorFiltros> createState() => _SelectorFiltrosState();
}

class _SelectorFiltrosState extends State<SelectorFiltros> {
  late List<GrupoFiltros> _filtros = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFiltros();
  }

  Future<void> _loadFiltros() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await widget.graphicsService.fetchFiltrosEmpresariales();

      if (!mounted) return;

      setState(() {
        _filtros = [
          GrupoFiltros(
            categoria: 'Área',
            filtros: ((response['Area'] as List?) ?? [])
                .map((e) => FiltroData.fromJson(e))
                .toList(),
          ),
          GrupoFiltros(
            categoria: 'Cargo',
            filtros: ((response['Cargo'] as List?) ?? [])
                .map((e) => FiltroData.fromJson(e))
                .toList(),
          ),
          GrupoFiltros(
            categoria: 'Centro costo',
            filtros: ((response['Centro costo'] as List?) ?? [])
                .map((e) => FiltroData.fromJson(e))
                .toList(),
          ),
          GrupoFiltros(
            categoria: 'Datos Familiares',
            filtros: ((response['DATOS FAMILIARES'] as List?) ?? [])
                .map((e) => FiltroData.fromJson(e))
                .toList(),
          ),
          GrupoFiltros(
            categoria: 'Genero',
            filtros: ((response['Genero'] as List?) ?? [])
                .map((e) => FiltroData.fromJson(e))
                .toList(),
          ),
          GrupoFiltros(
            categoria: 'Local',
            filtros: ((response['Local'] as List?) ?? [])
                .map((e) => FiltroData.fromJson(e))
                .toList(),
          ),
          GrupoFiltros(
            categoria: 'Nivel',
            filtros: ((response['Nivel'] as List?) ?? [])
                .map((e) => FiltroData.fromJson(e))
                .toList(),
          ),
        ];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Error cargando filtros: ${e.toString()}');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7876E1)),
          strokeWidth: 3,
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'No fue posible cargar la información de empleados en este momento.',
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HEADER con estilo morado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.deepPurple[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'FILTROS DISPONIBLES',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3E2B6B),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Color(0xFF3E2B6B)),
                  onPressed: widget.onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // LISTA DE FILTROS
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: _filtros.map((grupo) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF7876E1).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ExpansionTile(
                    leading: const Icon(
                      Icons.filter_alt_outlined,
                      color: Color(0xFF3E2B6B),
                      size: 22,
                    ),
                    title: Text(
                      grupo.categoria,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    initiallyExpanded: grupo.expandido,
                    onExpansionChanged: (expanded) {
                      if (!mounted) return;
                      setState(() => grupo.expandido = expanded);
                    },
                    children: grupo.filtros.map((filtro) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: CheckboxListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          title: Text(
                            filtro.descripcion,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          value: filtro.seleccionado,
                          onChanged: (value) {
                            if (!mounted) return;
                            setState(() {
                              filtro.seleccionado = value ?? false;
                            });
                          },
                          activeColor: const Color(0xFF7876E1),
                          checkColor: Colors.white,
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),

          // BOTÓN aplicar con estilo consistente
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: ElevatedButton(
              onPressed: () => widget.onFiltrosChanged(_filtros),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7876E1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                elevation: 1,
              ),
              child: const Text(
                'Aplicar Filtros',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
