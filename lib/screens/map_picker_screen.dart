import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:go_router/go_router.dart';

import '../models/building.dart';

/// Frame 06 - pick the building on the campus map (F7).
/// Returns the chosen building id to New Report with context.pop(id).
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _Pin {
  _Pin(this.building, this.x, this.y);
  final Building building;
  final double x; // 0..1 across the map image
  final double y; // 0..1 down the map image
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  List<_Pin> _pins = [];
  Building? _selected;

  @override
  void initState() {
    super.initState();
    _loadBuildings();
  }

  Future<void> _loadBuildings() async {
    final raw = await rootBundle.loadString('assets/buildings.json');
    final list = jsonDecode(raw) as List<dynamic>;
    setState(() {
      _pins = [
        for (final j in list.cast<Map<String, dynamic>>())
          _Pin(Building.fromJson(j), (j['mapX'] as num).toDouble(),
              (j['mapY'] as num).toDouble()),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Pick building')),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              maxScale: 4,
              child: LayoutBuilder(
                builder: (context, box) => Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset('assets/campus_map.png',
                          fit: BoxFit.fill),
                    ),
                    for (final p in _pins)
                      Positioned(
                        left: p.x * box.maxWidth - 22,
                        top: p.y * box.maxHeight - 22,
                        child: GestureDetector(
                          onTap: () => setState(() => _selected = p.building),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: _selected?.id == p.building.id
                                ? scheme.primary
                                : scheme.surface,
                            child: Text(
                              p.building.id == 'library'
                                  ? 'Lib'
                                  : '${p.building.number}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _selected?.id == p.building.id
                                    ? scheme.onPrimary
                                    : scheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(_selected?.name ?? 'Tap a building on the map',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _selected == null
                      ? null
                      : () => context.pop(_selected!.id),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
