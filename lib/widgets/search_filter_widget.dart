import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gestantes/providers/animal_provider.dart';

class SearchFilterWidget extends StatefulWidget {
  const SearchFilterWidget({Key? key}) : super(key: key);

  @override
  State<SearchFilterWidget> createState() => _SearchFilterWidgetState();
}

class _SearchFilterWidgetState extends State<SearchFilterWidget> {
  late TextEditingController _searchController;
  String? _selectedRaza;
  int? _selectedMeses;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnimalProvider>(
      builder: (context, provider, _) {
        final razas = provider.getRazas().toList();

        return Column(
          spacing: 12,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por ID...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          provider.clearFilters();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
                if (value.isEmpty) {
                  provider.clearFilters();
                } else {
                  provider.searchByIdVisible(value);
                }
              },
            ),
            if (_showFilters)
              Column(
                spacing: 12,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedRaza,
                    decoration: const InputDecoration(labelText: 'Filtrar por Raza'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todas')),
                      ...razas.map((r) => DropdownMenuItem(value: r, child: Text(r))),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedRaza = value);
                      if (value != null) {
                        provider.filterByRaza(value);
                      } else {
                        provider.clearFilters();
                      }
                    },
                  ),
                  DropdownButtonFormField<int>(
                    initialValue: _selectedMeses,
                    decoration: const InputDecoration(labelText: 'Filtrar por Meses'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Todos')),
                      ...List.generate(10, (i) => i)
                          .map((m) => DropdownMenuItem(value: m, child: Text('$m meses'))),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedMeses = value);
                      if (value != null) {
                        provider.filterByMeses(value);
                      } else {
                        provider.clearFilters();
                      }
                    },
                  ),
                ],
              ),
            Center(
              child: TextButton.icon(
                onPressed: () => setState(() => _showFilters = !_showFilters),
                icon: Icon(_showFilters ? Icons.expand_less : Icons.expand_more),
                label: Text(_showFilters ? 'Ocultar Filtros' : 'Mostrar Filtros'),
              ),
            ),
          ],
        );
      },
    );
  }
}
