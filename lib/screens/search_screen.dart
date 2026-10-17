import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/reports_provider.dart';
import '../services/report_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/report_card.dart';

/// Frame 04 - Search by text, category, building and date (F3).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';
  String? _category;
  String? _building;
  DateTime? _date;

  static const _buildings = ['4', '6', '22', '24', '59', '76', 'library'];

  void _clearFilters() => setState(() {
        _category = null;
        _building = null;
        _date = null;
      });

  Future<String?> _pick(String title, List<String> options,
      String Function(String) label) {
    return showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(title: Text(title)),
            for (final o in options)
              ListTile(
                title: Text(label(o)),
                onTap: () => Navigator.pop(context, o),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = context.watch<ReportsProvider>().search(
          query: _query,
          category: _category,
          buildingId: _building,
          onDate: _date,
        );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: SearchBar(
                hintText: 'Search reports',
                leading: const Icon(Icons.search),
                elevation: const WidgetStatePropertyAll(0),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  FilterChip(
                    label: Text(_category ?? 'Category'),
                    selected: _category != null,
                    onSelected: (_) async {
                      if (_category != null) {
                        setState(() => _category = null);
                        return;
                      }
                      final v = await _pick('Category',
                          ReportService.categories, (s) => s);
                      if (v != null) setState(() => _category = v);
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(_building == null
                        ? 'Building'
                        : ReportService.buildingLabel(_building!)),
                    selected: _building != null,
                    onSelected: (_) async {
                      if (_building != null) {
                        setState(() => _building = null);
                        return;
                      }
                      final v = await _pick('Building', _buildings,
                          ReportService.buildingLabel);
                      if (v != null) setState(() => _building = v);
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(_date == null
                        ? 'Date'
                        : DateFormat('MMM d').format(_date!)),
                    selected: _date != null,
                    onSelected: (_) async {
                      if (_date != null) {
                        setState(() => _date = null);
                        return;
                      }
                      final now = DateTime.now();
                      final v = await showDatePicker(
                        context: context,
                        firstDate: now.subtract(const Duration(days: 180)),
                        lastDate: now,
                        initialDate: now,
                      );
                      if (v != null) setState(() => _date = v);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: results.isEmpty
                  ? EmptyState(
                      icon: Icons.search,
                      message: 'No reports match',
                      actionLabel: 'Clear filters',
                      onAction: _clearFilters,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: results.length,
                      itemBuilder: (context, i) => ReportCard(
                        report: results[i],
                        showType: true,
                        onTap: () =>
                            context.push('/reports/${results[i].id}'),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
