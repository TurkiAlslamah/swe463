import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/report.dart';
import '../providers/reports_provider.dart';
import '../services/report_service.dart';

/// Frame 05 - New Report for a found or lost item (F1, F2).
class NewReportScreen extends StatefulWidget {
  const NewReportScreen({super.key});

  @override
  State<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _item = TextEditingController();
  final _description = TextEditingController();

  ReportType _type = ReportType.found;
  String? _category;
  String? _buildingId;
  XFile? _photo;
  DateTime _date = DateTime.now();
  bool _submitted = false;
  String? _postedId;

  @override
  void dispose() {
    _item.dispose();
    _description.dispose();
    super.dispose();
  }

  bool get _photoMissing => _type == ReportType.found && _photo == null;

  Future<void> _pickPhoto() async {
    final file = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file != null) setState(() => _photo = file);
  }

  Future<void> _pickBuilding() async {
    final id = await context.push<String>('/map-picker');
    if (id != null) setState(() => _buildingId = id);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 60)),
      lastDate: now,
      initialDate: _date,
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _post() async {
    setState(() => _submitted = true);
    final formOk = _formKey.currentState!.validate();
    if (!formOk || _photoMissing || _buildingId == null) return;

    final report = Report(
      id: 'r${DateTime.now().millisecondsSinceEpoch}',
      type: _type,
      title: _item.text.trim(),
      description: _description.text.trim(),
      category: _category ?? 'Other',
      buildingId: _buildingId!,
      photoUrl: _photo?.path,
      occurredAt: _date,
      status: ReportStatus.active,
      ownerId: ReportService.currentUserId,
    );
    await context.read<ReportsProvider>().addReport(report);
    setState(() => _postedId = report.id);
  }

  void _reset() {
    _item.clear();
    _description.clear();
    setState(() {
      _category = null;
      _buildingId = null;
      _photo = null;
      _date = DateTime.now();
      _submitted = false;
      _postedId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (_postedId != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('New report')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: scheme.primaryContainer,
                child: Icon(Icons.check_circle,
                    size: 40, color: scheme.primary),
              ),
              const SizedBox(height: 16),
              const Text('Report posted'),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () {
                  final id = _postedId!;
                  _reset();
                  context.push('/reports/$id');
                },
                child: const Text('View report'),
              ),
            ],
          ),
        ),
      );
    }

    final photoError = _submitted && _photoMissing;
    final buildingError = _submitted && _buildingId == null;

    return Scaffold(
      appBar: AppBar(title: const Text('New report')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SegmentedButton<ReportType>(
              segments: const [
                ButtonSegment(value: ReportType.found, label: Text('Found')),
                ButtonSegment(value: ReportType.lost, label: Text('Lost')),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickPhoto,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: photoError ? scheme.error : scheme.outline),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_photo == null ? Icons.photo_camera : Icons.check,
                        color: photoError ? scheme.error : scheme.primary),
                    const SizedBox(height: 4),
                    Text(_photo == null ? 'Add photo' : 'Photo added',
                        style: TextStyle(
                            color:
                                photoError ? scheme.error : scheme.primary)),
                  ],
                ),
              ),
            ),
            if (photoError)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 12),
                child: Text('Add a photo of the item',
                    style: TextStyle(color: scheme.error, fontSize: 12)),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _item,
              decoration: const InputDecoration(
                  labelText: 'Item', border: OutlineInputBorder()),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter the item name' : null,
            ),
            const SizedBox(height: 16),
            DropdownMenu<String>(
              expandedInsets: EdgeInsets.zero,
              label: const Text('Category'),
              initialSelection: _category,
              onSelected: (v) => setState(() => _category = v),
              dropdownMenuEntries: [
                for (final c in ReportService.categories)
                  DropdownMenuEntry(value: c, label: c),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              maxLines: 3,
              decoration: const InputDecoration(
                  labelText: 'Description', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickBuilding,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Building',
                  border: const OutlineInputBorder(),
                  errorText: buildingError ? 'Pick a building' : null,
                  suffixIcon: const Icon(Icons.location_on),
                ),
                child: Text(_buildingId == null
                    ? ''
                    : ReportService.buildingLabel(_buildingId!)),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(DateFormat('EEE, MMM d').format(_date)),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _post, child: const Text('Post report')),
          ],
        ),
      ),
    );
  }
}
