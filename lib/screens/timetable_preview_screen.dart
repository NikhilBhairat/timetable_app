import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:typed_data';
import '../models/models.dart';
import '../utils/utils.dart';

enum PreviewInitialAction {
  download,
  share,
}

class TimetablePreviewScreen extends StatefulWidget {
  final Timetable timetable;
  final PreviewInitialAction? initialAction;

  const TimetablePreviewScreen({
    super.key,
    required this.timetable,
    this.initialAction,
  });

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _runInitialAction();
    });
  }

  Future<void> _runInitialAction() async {
    switch (widget.initialAction) {
      case PreviewInitialAction.download:
        await _exportAsPng();
        break;
      case PreviewInitialAction.share:
        await _shareImage();
        break;
      case null:
        break;
    }
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
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 12),

                // Date
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blueGrey.shade100),
                  ),
                  child: Text(
                    'Date: ${DateTimeUtils.formatDate(widget.timetable.date)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 24),

                // Table
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 900),
                    child: Table(
                      border: TableBorder.all(color: Colors.blueGrey.shade400, width: 1),
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      columnWidths: _buildPreviewColumnWidths(standards.length),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.blueGrey.shade100),
                          children: [
                            _buildHeaderCell('From'),
                            _buildHeaderCell('To'),
                            ...standards.map(_buildHeaderCell),
                          ],
                        ),
                        ...List.generate(gridRows.length, (index) {
                          final row = gridRows[index];
                          return TableRow(
                            decoration: BoxDecoration(
                              color: index.isEven ? Colors.white : Colors.blueGrey.shade50,
                            ),
                            children: [
                              _buildBodyCell(row.fromTime),
                              _buildBodyCell(row.toTime),
                              ...standards.map((s) => _buildBodyCell(row.standardSubjects[s] ?? '--')),
                            ],
                          );
                        }),
                      ],
                    ),
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

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildBodyCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      child: Text(
        text.isEmpty ? '--' : text,
        style: const TextStyle(fontSize: 12.5),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
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
      0: const FlexColumnWidth(1.6),
      1: const FlexColumnWidth(1.6),
    };

    var column = 2;
    for (int i = 0; i < standardsCount; i++) {
      widths[column] = const FlexColumnWidth(2.2);
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
        // Reuse the same export pipeline so shared file matches generated image output.
        final file = await _saveBytesToFile(image, 'png');

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
    final targetDirectory = await _resolveExportDirectory();

    if (!await targetDirectory.exists()) {
      await targetDirectory.create(recursive: true);
    }

    final file = File(
      '${targetDirectory.path}${Platform.pathSeparator}timetable_${widget.timetable.date.millisecondsSinceEpoch}.$extension',
    );
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<Directory> _resolveExportDirectory() async {
    try {
      if (Platform.isAndroid) {
        final downloads = await getExternalStorageDirectories(type: StorageDirectory.downloads);
        if (downloads != null && downloads.isNotEmpty) {
          return Directory('${downloads.first.path}${Platform.pathSeparator}Timetable_app');
        }

        final external = await getExternalStorageDirectory();
        if (external != null) {
          return Directory('${external.path}${Platform.pathSeparator}Timetable_app');
        }
      }

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final downloads = await getDownloadsDirectory();
        if (downloads != null) {
          return Directory('${downloads.path}${Platform.pathSeparator}Timetable_app');
        }
      }

      final docs = await getApplicationDocumentsDirectory();
      return Directory('${docs.path}${Platform.pathSeparator}Timetable_app');
    } catch (_) {
      return Directory('${Directory.systemTemp.path}${Platform.pathSeparator}Timetable_app');
    }
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
