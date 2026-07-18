import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../constants/constants.dart';
import 'timetable_preview_screen.dart';

class TimetableEditorScreen extends StatefulWidget {
  final Timetable? timetable;

  const TimetableEditorScreen({super.key, this.timetable});

  @override
  State<TimetableEditorScreen> createState() => _TimetableEditorScreenState();
}

class _TimetableEditorScreenState extends State<TimetableEditorScreen> {
  late TextEditingController _academyNameController;
  late DateTime _selectedDate;
  late List<_EditorRow> _rows;
  List<String> _selectedStandards = [];

  @override
  void initState() {
    super.initState();
    if (widget.timetable != null) {
      _academyNameController = TextEditingController(
        text: (widget.timetable!.academyName == null || widget.timetable!.academyName!.trim().isEmpty)
            ? AppConstants.defaultAcademyName
            : widget.timetable!.academyName,
      );
      _selectedDate = widget.timetable!.date;
      _initializeRowsFromTimetable(widget.timetable!);
    } else {
      _academyNameController = TextEditingController(text: AppConstants.defaultAcademyName);
      _selectedDate = DateTime.now();
      _rows = [
        _EditorRow(fromTime: '', toTime: '', standardSubjects: {}),
      ];
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<StandardsProvider>().loadStandards();
      context.read<SubjectsProvider>().loadSubjects();
      context.read<TimeSlotsProvider>().loadTimeSlots();
    });
  }

  void _initializeRowsFromTimetable(Timetable timetable) {
    final grouped = <String, _EditorRow>{};
    final standards = <String>[];

    final fromTimetableStandard = timetable.standard
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    for (final s in fromTimetableStandard) {
      if (!standards.contains(s)) {
        standards.add(s);
      }
    }

    for (final row in timetable.rows) {
      String rowStandard = '';
      String rowSubject = row.subject;

      if (row.subject.contains('|||')) {
        final parts = row.subject.split('|||');
        rowStandard = parts.first.trim();
        rowSubject = parts.skip(1).join('|||').trim();
      } else if (fromTimetableStandard.isNotEmpty) {
        rowStandard = fromTimetableStandard.first;
      }

      final key = '${row.fromTime}__${row.toTime}';
      final groupedRow = grouped.putIfAbsent(
        key,
        () => _EditorRow(
          fromTime: row.fromTime,
          toTime: row.toTime,
          standardSubjects: {},
        ),
      );

      if (rowStandard.isNotEmpty) {
        groupedRow.standardSubjects[rowStandard] = rowSubject;
        if (!standards.contains(rowStandard)) {
          standards.add(rowStandard);
        }
      }
    }

    _rows = grouped.values.toList();
    if (_rows.isEmpty) {
      _rows = [
        _EditorRow(fromTime: '', toTime: '', standardSubjects: {}),
      ];
    }

    _selectedStandards = standards;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.timetable == null ? 'Create Timetable' : 'Edit Timetable'),
        actions: [
          IconButton(
            tooltip: 'View Timetable',
            icon: const Icon(Icons.visibility),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TimetablePreviewScreen(timetable: _buildTimetableFromForm()),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Academy Name
            TextField(
              controller: _academyNameController,
              decoration: const InputDecoration(
                labelText: 'Academy Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Date Picker
            ListTile(
              title: const Text('Date'),
              subtitle: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            const SizedBox(height: 24),

            // Timetable Rows (Word-style table editor)
            const Text(
              'Class Schedule',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Consumer3<TimeSlotsProvider, SubjectsProvider, StandardsProvider>(
              builder: (context, timeProvider, subjectProvider, standardsProvider, _) {
                return _buildScheduleTable(timeProvider, subjectProvider, standardsProvider);
              },
            ),
            const SizedBox(height: 16),

            // Add Row Button
            OutlinedButton.icon(
              onPressed: _addRow,
              icon: const Icon(Icons.add),
              label: const Text('Add Period'),
            ),
            const SizedBox(height: 24),

            // Save Button
            FilledButton(
              onPressed: _saveTimetable,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Save Timetable',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleTable(
    TimeSlotsProvider timeProvider,
    SubjectsProvider subjectProvider,
    StandardsProvider standardsProvider,
  ) {
    final isLoading = timeProvider.isLoading || subjectProvider.isLoading;
    final allStandards = standardsProvider.standards.map((s) => s.name).toList();
    _ensureDefaultSelectedStandards(allStandards);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Standards Columns',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            OutlinedButton.icon(
              onPressed: allStandards.where((s) => !_selectedStandards.contains(s)).isEmpty
                  ? null
                  : () => _showAddStandardDialog(allStandards),
              icon: const Icon(Icons.add),
              label: const Text('Add Standard'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedStandards.isEmpty)
          Text(
            standardsProvider.isLoading ? 'Loading standards...' : 'No standard column selected.',
            style: Theme.of(context).textTheme.bodyMedium,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedStandards
                .map(
                  (standard) => Chip(
                    label: Text(standard),
                    onDeleted: () => _removeStandardColumn(standard),
                  ),
                )
                .toList(),
          ),
        const SizedBox(height: 8),
        if (isLoading) const LinearProgressIndicator(),
        if (isLoading) const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return Table(
              border: TableBorder.all(color: Colors.black54, width: 1),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: _buildColumnWidths(),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  children: [
                    const _TableHeaderCell('No.'),
                    const _TableHeaderCell('From Time'),
                    const _TableHeaderCell('To Time'),
                    ..._selectedStandards.map((s) => _TableHeaderCell(s)),
                    const _TableHeaderCell('Del'),
                  ],
                ),
                ...List.generate(_rows.length, (index) {
                  return TableRow(
                    children: [
                      _TableBodyCell(
                        child: Text(
                          '${index + 1}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      _TableBodyCell(
                        child: _buildCellDropdown(
                          value: _rows[index].fromTime,
                          items: timeProvider.timeSlots.map((s) => s.time).toList(),
                          placeholder: '--',
                          onChanged: (value) {
                            setState(() {
                              _rows[index].fromTime = value ?? '';
                            });
                          },
                        ),
                      ),
                      _TableBodyCell(
                        child: _buildCellDropdown(
                          value: _rows[index].toTime,
                          items: timeProvider.timeSlots.map((s) => s.time).toList(),
                          placeholder: '--',
                          onChanged: (value) {
                            setState(() {
                              _rows[index].toTime = value ?? '';
                            });
                          },
                        ),
                      ),
                      ..._selectedStandards.map(
                        (standard) => _TableBodyCell(
                          child: _buildCellDropdown(
                            value: _rows[index].standardSubjects[standard] ?? '',
                            items: subjectProvider.subjects.map((s) => s.name).toList(),
                            placeholder: '--',
                            onChanged: (value) {
                              setState(() {
                                _rows[index].standardSubjects[standard] = value ?? '';
                              });
                            },
                          ),
                        ),
                      ),
                      _TableBodyCell(
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: _rows.length == 1
                              ? null
                              : () {
                                  setState(() {
                                    _rows.removeAt(index);
                                  });
                                },
                        ),
                      ),
                    ],
                  );
                }),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Tap table cells to select values directly. Standards are column headers.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Map<int, TableColumnWidth> _buildColumnWidths() {
    final widths = <int, TableColumnWidth>{
      0: const FixedColumnWidth(56),
      1: const FlexColumnWidth(2),
      2: const FlexColumnWidth(2),
    };

    var colIndex = 3;
    for (int i = 0; i < _selectedStandards.length; i++) {
      widths[colIndex] = const FlexColumnWidth(2);
      colIndex++;
    }

    widths[colIndex] = const FixedColumnWidth(64);
    return widths;
  }

  Widget _buildCellDropdown({
    required String value,
    required List<String> items,
    required String placeholder,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: value.isEmpty ? null : value,
        hint: Text(placeholder),
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(),
        onChanged: items.isEmpty ? null : onChanged,
      ),
    );
  }

  void _addRow() {
    setState(() {
      _rows.add(_EditorRow(fromTime: '', toTime: '', standardSubjects: {}));
    });
  }

  void _ensureDefaultSelectedStandards(List<String> allStandards) {
    if (_selectedStandards.isNotEmpty || allStandards.isEmpty) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _selectedStandards.isNotEmpty) {
        return;
      }
      setState(() {
        _selectedStandards = [allStandards.first];
      });
    });
  }

  Future<void> _showAddStandardDialog(List<String> allStandards) async {
    final available = allStandards.where((s) => !_selectedStandards.contains(s)).toList();
    if (available.isEmpty) {
      return;
    }

    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Add Standard Column'),
          children: available
              .map(
                (name) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, name),
                  child: Text(name),
                ),
              )
              .toList(),
        );
      },
    );

    if (selected == null || !mounted) {
      return;
    }

    setState(() {
      _selectedStandards.add(selected);
      for (final row in _rows) {
        row.standardSubjects.putIfAbsent(selected, () => '');
      }
    });
  }

  void _removeStandardColumn(String standard) {
    if (_selectedStandards.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one standard column is required.')),
      );
      return;
    }

    setState(() {
      _selectedStandards.remove(standard);
      for (final row in _rows) {
        row.standardSubjects.remove(standard);
      }
    });
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveTimetable() {
    final timetable = _buildTimetableFromForm();

    if (widget.timetable == null) {
      context.read<TimetableProvider>().createTimetable(timetable);
    } else {
      context.read<TimetableProvider>().updateTimetable(timetable);
    }

    Navigator.of(context).pop();
  }

  Timetable _buildTimetableFromForm() {
    final serializedRows = <TimetableRow>[];

    if (_selectedStandards.isEmpty) {
      for (final row in _rows) {
        serializedRows.add(
          TimetableRow(
            fromTime: row.fromTime,
            toTime: row.toTime,
            subject: '',
          ),
        );
      }
    } else {
      for (final row in _rows) {
        for (final standard in _selectedStandards) {
          final value = row.standardSubjects[standard] ?? '';
          serializedRows.add(
            TimetableRow(
              fromTime: row.fromTime,
              toTime: row.toTime,
              subject: '$standard|||$value',
            ),
          );
        }
      }
    }

    return Timetable(
      id: widget.timetable?.id,
      standard: _selectedStandards.join(', '),
      date: _selectedDate,
      academyName: _academyNameController.text,
      rows: serializedRows,
      createdAt: widget.timetable?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _academyNameController.dispose();
    super.dispose();
  }
}

class _TableHeaderCell extends StatelessWidget {
  final String label;

  const _TableHeaderCell(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _TableBodyCell extends StatelessWidget {
  final Widget child;

  const _TableBodyCell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: child,
    );
  }
}

class _EditorRow {
  String fromTime;
  String toTime;
  Map<String, String> standardSubjects;

  _EditorRow({
    required this.fromTime,
    required this.toTime,
    required this.standardSubjects,
  });
}
