import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/building.dart';
import '../services/building_service.dart';
import '../widgets/empty_state.dart';

/// Frame 06 - pick the building on the campus map (F7).
/// Returns the chosen building id to New Report with context.pop(id).
class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late Future<List<Building>> _buildings = BuildingService.loadAll();
  Building? _selected;

  void _retry() => setState(() => _buildings = BuildingService.loadAll());

  void _select(Building b) => setState(() => _selected = b);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick building')),
      body: FutureBuilder<List<Building>>(
        future: _buildings,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return EmptyState(
              icon: Icons.map_outlined,
              message: 'Could not load the campus map',
              actionLabel: 'Retry',
              onAction: _retry,
            );
          }
          final buildings = snapshot.data ?? const <Building>[];
          if (buildings.isEmpty) {
            return const EmptyState(
                icon: Icons.map_outlined, message: 'No buildings found');
          }
          return Column(
            children: [
              Expanded(
                child: InteractiveViewer(
                  maxScale: 4,
                  child: _CampusMap(
                    buildings: buildings,
                    selectedId: _selected?.id,
                    onTap: _select,
                  ),
                ),
              ),
              _BuildingChips(
                buildings: buildings,
                selectedId: _selected?.id,
                onTap: _select,
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _selected?.name ?? 'Tap a building on the map',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
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
              ),
            ],
          );
        },
      ),
    );
  }
}

/// The campus image with one tappable pin per building.
class _CampusMap extends StatelessWidget {
  const _CampusMap({
    required this.buildings,
    required this.selectedId,
    required this.onTap,
  });

  final List<Building> buildings;
  final String? selectedId;
  final ValueChanged<Building> onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, box) => Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/campus_map.png', fit: BoxFit.fill),
          ),
          for (final b in buildings)
            Positioned(
              left: b.mapX * box.maxWidth - 22,
              top: b.mapY * box.maxHeight - 22,
              child: GestureDetector(
                onTap: () => onTap(b),
                child: AnimatedScale(
                  scale: b.id == selectedId ? 1.2 : 1,
                  duration: const Duration(milliseconds: 150),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        b.id == selectedId ? scheme.primary : scheme.surface,
                    child: Text(
                      b.shortLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: b.id == selectedId
                            ? scheme.onPrimary
                            : scheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Same buildings as a scrollable chip list (easier on small screens).
class _BuildingChips extends StatelessWidget {
  const _BuildingChips({
    required this.buildings,
    required this.selectedId,
    required this.onTap,
  });

  final List<Building> buildings;
  final String? selectedId;
  final ValueChanged<Building> onTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          for (final b in buildings)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(b.name),
                selected: b.id == selectedId,
                onSelected: (_) => onTap(b),
              ),
            ),
        ],
      ),
    );
  }
}

