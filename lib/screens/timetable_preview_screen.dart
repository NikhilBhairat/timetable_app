import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:typed_data';
import '../models/models.dart';
import '../utils/utils.dart';

class TimetablePreviewScreen extends StatefulWidget {
  final Timetable timetable;

  const TimetablePreviewScreen({super.key, required this.timetable});

  @override
  State<TimetablePreviewScreen> createState() => _TimetablePreviewScreenState();
}

class _TimetablePreviewScreenState extends State<TimetablePreviewScreen> {
  late ScreenshotController _screenshotController;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _screenshotController = ScreenshotController();
  }

  @override
  Widget build(BuildContext context) {
    final standards = _extractStandards();
    final gridRows = _buildGridRows(standards);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable Preview'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'png',
                child: Row(
                  children: [
                    Icon(Icons.image),
                    SizedBox(width: 8),
                    Text('Download PNG'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'jpg',
                child: Row(
                  children: [
                    Icon(Icons.image),
                    SizedBox(width: 8),
                    Text('Download JPG'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'png') {
                _exportAsPng();
              } else if (value == 'jpg') {
                _exportAsJpg();
              } else if (value == 'share') {
                _shareImage();
              }
            },
          ),
        ],
      ),
      body: Screenshot(
        controller: _screenshotController,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Academy Name
                if (widget.timetable.academyName?.isNotEmpty ?? false)
                  Text(
                    widget.timetable.academyName!,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 8),

                // Date
                Text(
                  'Date: ${DateTimeUtils.formatDate(widget.timetable.date)}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Table
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    border: TableBorder.all(color: Colors.black),
                    columnWidths: _buildPreviewColumnWidths(standards.length),
                    children: [
                      // Header
                      TableRow(
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                        ),
                        children: [
                          _buildTableCell('From', isHeader: true),
                          _buildTableCell('To', isHeader: true),
                          ...standards.map((s) => _buildTableCell(s, isHeader: true)),
                        ],
                      ),
                      // Data rows
                      ...gridRows.map((row) {
                        return TableRow(
                          children: [
                            _buildTableCell(row.fromTime),
                            _buildTableCell(row.toTime),
                            ...standards.map((s) => _buildTableCell(row.standardSubjects[s] ?? '--')),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _isExporting
          ? const FloatingActionButton(
              onPressed: null,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : null,
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text.isEmpty ? '--' : text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: isHeader ? 14 : 12,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  List<String> _extractStandards() {
    final standards = <String>[];

    for (final standard in widget.timetable.standard.split(',')) {
      final trimmed = standard.trim();
      if (trimmed.isNotEmpty && !standards.contains(trimmed)) {
        standards.add(trimmed);
      }
    }

    for (final row in widget.timetable.rows) {
      if (!row.subject.contains('|||')) {
        continue;
      }
      final parsed = row.subject.split('|||').first.trim();
      if (parsed.isNotEmpty && !standards.contains(parsed)) {
        standards.add(parsed);
      }
    }

    if (standards.isEmpty) {
      standards.add('Standard');
    }

    return standards;
  }

  List<_PreviewGridRow> _buildGridRows(List<String> standards) {
    final grouped = <String, _PreviewGridRow>{};

    for (final row in widget.timetable.rows) {
      String standard = standards.first;
      String value = row.subject;

      if (row.subject.contains('|||')) {
        final parts = row.subject.split('|||');
        standard = parts.first.trim();
        value = parts.skip(1).join('|||').trim();
      }

      final key = '${row.fromTime}__${row.toTime}';
      final gridRow = grouped.putIfAbsent(
        key,
        () => _PreviewGridRow(
          fromTime: row.fromTime,
          toTime: row.toTime,
          standardSubjects: {},
        ),
      );

      gridRow.standardSubjects[standard] = value;
    }

    return grouped.values.toList();
  }

  Map<int, TableColumnWidth> _buildPreviewColumnWidths(int standardsCount) {
    final widths = <int, TableColumnWidth>{
      0: const FixedColumnWidth(120),
      1: const FixedColumnWidth(120),
    };

    var column = 2;
    for (int i = 0; i < standardsCount; i++) {
      widths[column] = const FixedColumnWidth(180);
      column++;
    }

    return widths;
  }

  Future<void> _exportAsPng() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final image = await _screenshotController.capture();
      if (image != null) {
        final file = await _saveBytesToFile(image, 'png');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PNG saved: ${file.path}'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _exportAsJpg() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final image = await _screenshotController.capture();
      if (image != null) {
        final decoded = img.decodeImage(image);
        final jpgBytes = decoded == null
            ? image
            : Uint8List.fromList(img.encodeJpg(decoded, quality: 90));
        final file = await _saveBytesToFile(jpgBytes, 'jpg');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('JPG saved: ${file.path}'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _shareImage() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final image = await _screenshotController.capture();
      if (image != null) {
        final tempDir = Directory.systemTemp;
        final file = File('${tempDir.path}/timetable.png');
        await file.writeAsBytes(image);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Check out my timetable!',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<File> _saveBytesToFile(Uint8List bytes, String extension) async {
    Directory targetDirectory;
    try {
      final appDirectory = await getApplicationDocumentsDirectory();
      targetDirectory = Directory('${appDirectory.path}${Platform.pathSeparator}exports');
    } catch (_) {
      targetDirectory = Directory('${Directory.systemTemp.path}${Platform.pathSeparator}exports');
    }

    if (!await targetDirectory.exists()) {
      await targetDirectory.create(recursive: true);
    }

    final file = File(
      '${targetDirectory.path}${Platform.pathSeparator}timetable_${widget.timetable.date.millisecondsSinceEpoch}.$extension',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class _PreviewGridRow {
  final String fromTime;
  final String toTime;
  final Map<String, String> standardSubjects;

  _PreviewGridRow({
    required this.fromTime,
    required this.toTime,
    required this.standardSubjects,
  });
}
