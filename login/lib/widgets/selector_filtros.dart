import 'package:flutter/material.dart';
import 'package:login/Models/filtro_data.dart';
import 'package:login/Apis/api_graphics_services.dart';

class SelectorFiltros extends StatefulWidget {
  final ApiGraphicsService graphicsService;
  final Function(List<GrupoFiltros>) onFiltrosChanged;

  const SelectorFiltros({
    super.key,
    required this.graphicsService,
    required this.onFiltrosChanged,
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
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await widget.graphicsService.fetchFiltrosEmpresariales();
      
      // Usar operadores seguros y valores por defecto
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
      setState(() => _error = 'Error cargando filtros: ${e.toString()}');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Text(_error!, style: TextStyle(color: Colors.red));

    return Column(
      children: [
        Expanded(
          child: ListView(
            children: _filtros.map((grupo) {
              return ExpansionTile(
                title: Text(grupo.categoria, style: const TextStyle(fontWeight: FontWeight.bold)),
                initiallyExpanded: grupo.expandido,
                onExpansionChanged: (expanded) => setState(() => grupo.expandido = expanded),
                children: grupo.filtros.map((filtro) {
                  return CheckboxListTile(
                    title: Text(filtro.descripcion),
                    value: filtro.seleccionado,
                    onChanged: (value) {
                      setState(() {
                        filtro.seleccionado = value ?? false;
                        widget.onFiltrosChanged(_filtros);
                      });
                    },
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
        ElevatedButton(
          onPressed: () => widget.onFiltrosChanged(_filtros),
          child: const Text('Aplicar Filtros'),
        ),
      ],
    );
  }
}