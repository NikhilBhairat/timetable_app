import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/utils.dart';
import 'timetable_preview_screen.dart';
import 'timetable_editor_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TimetableProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.timetables.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('No timetables yet'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.timetables.length,
            itemBuilder: (context, index) {
              final timetable = provider.timetables[index];
              return Card(
                child: ListTile(
                  title: Text('${timetable.standard} - ${DateTimeUtils.formatDate(timetable.date)}'),
                  subtitle: Text('${timetable.rows.length} periods'),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility),
                            SizedBox(width: 8),
                            Text('View'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy),
                            SizedBox(width: 8),
                            Text('Duplicate'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'download',
                        child: Row(
                          children: [
                            Icon(Icons.download),
                            SizedBox(width: 8),
                            Text('Download'),
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
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      _handleMenuAction(context, value, timetable);
                    },
                  ),
                  onTap: () {
                    final timetableProvider = context.read<TimetableProvider>();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TimetableEditorScreen(timetable: timetable),
                      ),
                    ).then((_) {
                      timetableProvider.loadTimetables();
                    });
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String value, Timetable timetable) {
    switch (value) {
      case 'view':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TimetablePreviewScreen(timetable: timetable),
          ),
        );
        break;
      case 'edit':
        final timetableProvider = context.read<TimetableProvider>();
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (context) => TimetableEditorScreen(timetable: timetable),
              ),
            )
            .then((_) {
              timetableProvider.loadTimetables();
            });
        break;
      case 'duplicate':
        _showDuplicateDialog(context, timetable);
        break;
      case 'download':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TimetablePreviewScreen(
              timetable: timetable,
              initialAction: PreviewInitialAction.download,
            ),
          ),
        );
        break;
      case 'share':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TimetablePreviewScreen(
              timetable: timetable,
              initialAction: PreviewInitialAction.share,
            ),
          ),
        );
        break;
      case 'delete':
        _showDeleteDialog(context, timetable);
        break;
    }
  }

  void _showDuplicateDialog(BuildContext context, Timetable timetable) {
    _duplicateTimetable(context, timetable);
  }

  Future<void> _duplicateTimetable(BuildContext context, Timetable timetable) async {
    final timetableProvider = context.read<TimetableProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null || timetable.id == null) {
      return;
    }

    try {
      await timetableProvider.duplicateTimetable(timetable.id!, selectedDate);
      messenger.showSnackBar(
        const SnackBar(content: Text('Timetable duplicated successfully')),
      );
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Failed to duplicate timetable')),
      );
    }
  }

  void _showDeleteDialog(BuildContext context, Timetable timetable) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Timetable'),
        content: const Text('Are you sure you want to delete this timetable?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TimetableProvider>().deleteTimetable(timetable.id!);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
