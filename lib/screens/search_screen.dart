import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/report.dart';
import '../providers/reports_provider.dart';
import '../services/report_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/report_card.dart';
import '../widgets/report_list_skeleton.dart';

/// Frame 04 - Search by text, category, building and date (F3).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _search = TextEditingController();
  String _query = '';
  String? _category;
  String? _building;
  DateTime? _date;

  static const _buildings = ['4', '6', 'library', '22', '24', '59', '76'];

  bool get _hasFilters =>
      _query.isNotEmpty ||
      _category != null ||
      _building != null ||
      _date != null;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clearText() {
    _search.clear();
    setState(() => _query = '');
  }

  void _clearAll() {
    _search.clear();
    setState(() {
      _query = '';
      _category = null;
      _building = null;
      _date = null;
    });
  }

  Future<String?> _pick(
      String title, List<String> options, String Function(String) label) {
    return showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title:
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
            ),
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

  // Tapping a selected chip clears it; tapping an empty chip opens a picker.
  Future<void> _onCategory() async {
    if (_category != null) {
      setState(() => _category = null);
      return;
    }
    final v = await _pick('Category', ReportService.categories, (s) => s);
    if (v != null) setState(() => _category = v);
  }

  Future<void> _onBuilding() async {
    if (_building != null) {
      setState(() => _building = null);
      return;
    }
    final v = await _pick('Building', _buildings, ReportService.buildingLabel);
    if (v != null) setState(() => _building = v);
  }

  Future<void> _onDate() async {
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
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportsProvider>();
    final results = provider.search(
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
                controller: _search,
                hintText: 'Search reports',
                leading: const Icon(Icons.search),
                trailing: [
                  if (_query.isNotEmpty)
                    IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.close),
                      onPressed: _clearText,
                    ),
                ],
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
                    onSelected: (_) => _onCategory(),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(_building == null
                        ? 'Building'
                        : ReportService.buildingLabel(_building!)),
                    selected: _building != null,
                    onSelected: (_) => _onBuilding(),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(_date == null
                        ? 'Date'
                        : DateFormat('MMM d').format(_date!)),
                    selected: _date != null,
                    onSelected: (_) => _onDate(),
                  ),
                ],
              ),
            ),
            if (_hasFilters && !provider.isLoading && provider.error == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    Text(
                      results.length == 1
                          ? '1 result'
                          : '${results.length} results',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const Spacer(),
                    TextButton(
                        onPressed: _clearAll, child: const Text('Clear all')),
                  ],
                ),
              ),
            Expanded(child: _buildResults(provider, results)),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(ReportsProvider provider, List<Report> results) {
    if (provider.isLoading && provider.reports.isEmpty) {
      return const ReportListSkeleton();
    }
    if (provider.error != null) {
      return EmptyState(
        icon: Icons.cloud_off,
        message: provider.error!,
        actionLabel: 'Retry',
        onAction: provider.loadReports,
      );
    }
    if (results.isEmpty) {
      return EmptyState(
        icon: Icons.search,
        message: 'No reports match',
        actionLabel: 'Clear filters',
        onAction: _clearAll,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: results.length,
      itemBuilder: (context, i) => ReportCard(
        report: results[i],
        showType: true,
        onTap: () => context.push('/reports/${results[i].id}'),
      ),
    );
  }
}
