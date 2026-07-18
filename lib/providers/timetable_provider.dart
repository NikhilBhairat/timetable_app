import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class TimetableProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Timetable> _timetables = [];
  Timetable? _currentTimetable;
  bool _isLoading = false;

  List<Timetable> get timetables => _timetables;
  Timetable? get currentTimetable => _currentTimetable;
  bool get isLoading => _isLoading;

  Future<void> loadTimetables() async {
    _isLoading = true;
    notifyListeners();
    try {
      _timetables = await _databaseService.getAllTimetables();
      for (var timetable in _timetables) {
        timetable.rows = await _databaseService.getTimetableRows(timetable.id!);
      }
    } catch (e) {
      if (e is UnsupportedError) {
        print('Database not supported on this platform: $e');
        _timetables = [];
      } else {
        print('Error loading timetables: $e');
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTimetable(int id) async {
    _currentTimetable = await _databaseService.getTimetableById(id);
    if (_currentTimetable != null) {
      _currentTimetable!.rows = await _databaseService.getTimetableRows(id);
    }
    notifyListeners();
  }

  Future<int> createTimetable(Timetable timetable) async {
    final id = await _databaseService.insertTimetable(timetable);
    timetable.id = id;
    
    for (var row in timetable.rows) {
      await _databaseService.insertTimetableRow(id, row);
    }
    
    _currentTimetable = timetable;
    await loadTimetables();
    return id;
  }

  Future<void> updateTimetable(Timetable timetable) async {
    await _databaseService.updateTimetable(timetable);
    
    // Delete old rows
    final oldRows = await _databaseService.getTimetableRows(timetable.id!);
    for (var row in oldRows) {
      await _databaseService.deleteTimetableRow(row.id!);
    }
    
    // Insert new rows
    for (var row in timetable.rows) {
      await _databaseService.insertTimetableRow(timetable.id!, row);
    }
    
    _currentTimetable = timetable;
    await loadTimetables();
    notifyListeners();
  }

  Future<void> deleteTimetable(int id) async {
    await _databaseService.deleteTimetable(id);
    await loadTimetables();
  }

  Future<void> duplicateTimetable(int id, DateTime newDate) async {
    final original = _timetables.firstWhere((t) => t.id == id);
    final newTimetable = Timetable(
      standard: original.standard,
      date: newDate,
      academyName: original.academyName,
      rows: original.rows.map((r) => TimetableRow(
        fromTime: r.fromTime,
        toTime: r.toTime,
        subject: r.subject,
      )).toList(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await createTimetable(newTimetable);
  }
}
