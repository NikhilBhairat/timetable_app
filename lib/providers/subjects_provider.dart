import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class SubjectsProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Subject> _subjects = [];
  bool _isLoading = false;

  List<Subject> get subjects => _subjects;
  bool get isLoading => _isLoading;

  Future<void> loadSubjects() async {
    _isLoading = true;
    notifyListeners();
    try {
      _subjects = await _databaseService.getAllSubjects();
    } catch (e) {
      if (e is UnsupportedError) {
        print('Database not supported on this platform: $e');
        // Provide default subjects for web
        _subjects = _getDefaultSubjects();
      } else {
        print('Error loading subjects: $e');
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  List<Subject> _getDefaultSubjects() {
    final defaults = [
      'Maths', 'Maths (Sn)', 'Science', 'Science (Sn)',
      'English (Ar)', 'English (An)', 'English (Sn)', 'English (N)',
      'Sanskrit', 'Marathi', 'SST (An)', 'SST (N)',
      'Hindi (Sn)', 'Hindi (An)', 'Geography (N)', 'Geography (An)',
      'Exam', 'Holiday'
    ];
    return List.generate(defaults.length, (i) => Subject(id: i + 1, name: defaults[i], displayOrder: i));
  }

  Future<void> addSubject(Subject subject) async {
    await _databaseService.insertSubject(subject);
    await loadSubjects();
  }

  Future<void> updateSubject(Subject subject) async {
    await _databaseService.updateSubject(subject);
    await loadSubjects();
  }

  Future<void> deleteSubject(int id) async {
    await _databaseService.deleteSubject(id);
    await loadSubjects();
  }

  Future<void> reorderSubjects(List<Subject> reorderedList) async {
    for (int i = 0; i < reorderedList.length; i++) {
      reorderedList[i].displayOrder = i;
      await _databaseService.updateSubject(reorderedList[i]);
    }
    _subjects = reorderedList;
    notifyListeners();
  }
}
