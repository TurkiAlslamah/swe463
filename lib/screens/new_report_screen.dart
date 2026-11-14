import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/report.dart';
import '../providers/auth_provider.dart';
import '../providers/reports_provider.dart';
import '../services/report_service.dart';

/// Frame 05 - New Report for a found or lost item (F1, F2).
///
/// Main end-to-end flow of Phase 3:
/// form input -> validation -> ReportsProvider -> Supabase (or the local
/// demo store) -> "Report posted" -> Report Details.
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
  Uint8List? _photoBytes;
  DateTime _when = DateTime.now();
  bool _submitted = false;
  String? _postedId;

  @override
  void dispose() {
    _item.dispose();
    _description.dispose();
    super.dispose();
  }

  /// A photo is required for found items and optional for lost items.
  bool get _photoMissing => _type == ReportType.found && _photo == null;

  Future<void> _pickPhoto() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1600,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _photo = file;
        _photoBytes = bytes;
      });
    } catch (_) {
      _showMessage('Could not open the photo library');
    }
  }

  void _removePhoto() => setState(() {
        _photo = null;
        _photoBytes = null;
      });

  Future<void> _pickBuilding() async {
    final id = await context.push<String>('/map-picker');
    if (id == null || !mounted) return;
    setState(() => _buildingId = id);
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 60)),
      lastDate: now,
      initialDate: _when.isAfter(now) ? now : _when,
    );
    if (date == null) return;
    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_when),
    );
    if (!mounted) return;
    final t = time ?? TimeOfDay.fromDateTime(_when);
    var picked = DateTime(date.year, date.month, date.day, t.hour, t.minute);
    if (picked.isAfter(now)) picked = now; // cannot be in the future
    setState(() => _when = picked);
  }

  Future<void> _post() async {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    final formOk = _formKey.currentState!.validate();
    if (!formOk || _photoMissing || _category == null || _buildingId == null) {
      _showMessage('Fill in the fields marked in red');
      return;
    }

    final reports = context.read<ReportsProvider>();
    final draft = Report(
      id: '', // the database (or the local store) gives the real id
      type: _type,
      title: _item.text.trim(),
      description: _description.text.trim(),
      category: _category!,
      buildingId: _buildingId!,
      occurredAt: _when,
      status: ReportStatus.active,
      ownerId: context.read<AuthProvider>().user?.id ?? '',
    );

    try {
      final saved = await reports.addReport(draft, photo: _photo);
      if (!mounted) return;
      setState(() => _postedId = saved.id);
    } catch (e) {
      _showMessage(ReportService.describe(e));
    }
  }

  void _reset() {
    _item.clear();
    _description.clear();
    setState(() {
      _type = ReportType.found;
      _category = null;
      _buildingId = null;
      _photo = null;
      _photoBytes = null;
      _when = DateTime.now();
      _submitted = false;
      _postedId = null;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (_postedId != null) return _buildSuccess(context);

    final scheme = Theme.of(context).colorScheme;
    final posting = context.watch<ReportsProvider>().isPosting;
    final photoError = _submitted && _photoMissing;
    final categoryError = _submitted && _category == null;
    final buildingError = _submitted && _buildingId == null;

    return Scaffold(
      appBar: AppBar(title: const Text('New report')),
      body: AbsorbPointer(
        absorbing: posting,
        child: Form(
          key: _formKey,
          autovalidateMode: _submitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
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
              _PhotoBox(
                bytes: _photoBytes,
                hasError: photoError,
                optional: _type == ReportType.lost,
                onPick: _pickPhoto,
                onRemove: _removePhoto,
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
                maxLength: 60,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Item',
                  hintText: 'e.g. Black AirPods case',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final text = v?.trim() ?? '';
                  if (text.isEmpty) return 'Enter the item name';
                  if (text.length < 3) return 'Use at least 3 characters';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              DropdownMenu<String>(
                expandedInsets: EdgeInsets.zero,
                label: const Text('Category'),
                initialSelection: _category,
                errorText: categoryError ? 'Pick a category' : null,
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
                maxLength: 300,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: _type == ReportType.found
                      ? 'Description (where exactly you found it)'
                      : 'Description (color, brand, marks)',
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _pickBuilding,
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Building',
                    border: const OutlineInputBorder(),
                    errorText: buildingError ? 'Pick a building' : null,
                    suffixIcon: const Icon(Icons.location_on),
                  ),
                  child: Text(_buildingId == null
                      ? 'Tap to pick on the campus map'
                      : ReportService.buildingLabel(_buildingId!)),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDateTime,
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText:
                        _type == ReportType.found ? 'Date found' : 'Date lost',
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('EEE, MMM d · h:mm a').format(_when)),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: posting ? null : _post,
                child: posting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Post report'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('New report')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: scheme.primaryContainer,
              child: Icon(Icons.check_circle, size: 40, color: scheme.primary),
            ),
            const SizedBox(height: 16),
            Text('Report posted',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () {
                final id = _postedId!;
                _reset();
                context.push('/reports/$id');
              },
              child: const Text('View report'),
            ),
            TextButton(
              onPressed: _reset,
              child: const Text('Post another report'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Photo area: "Add photo" button, or a preview with change/remove actions.
class _PhotoBox extends StatelessWidget {
  const _PhotoBox({
    required this.bytes,
    required this.hasError,
    required this.optional,
    required this.onPick,
    required this.onRemove,
  });

  final Uint8List? bytes;
  final bool hasError;
  final bool optional;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = hasError ? scheme.error : scheme.primary;
    final image = bytes;

    if (image != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 180,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(image, fit: BoxFit.cover),
              Positioned(
                right: 8,
                top: 8,
                child: Row(
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Change photo',
                      onPressed: onPick,
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton.filledTonal(
                      tooltip: 'Remove photo',
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: hasError ? scheme.error : scheme.outline),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera, color: color),
            const SizedBox(height: 4),
            Text(optional ? 'Add photo (optional)' : 'Add photo',
                style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
}
