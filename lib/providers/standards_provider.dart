import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class StandardsProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Standard> _standards = [];
  bool _isLoading = false;

  List<Standard> get standards => _standards;
  bool get isLoading => _isLoading;

  Future<void> loadStandards() async {
    _isLoading = true;
    notifyListeners();
    try {
      _standards = await _databaseService.getAllStandards();
    } catch (e) {
      if (e is UnsupportedError) {
        print('Database not supported on this platform: $e');
        // Provide default standards for web
        _standards = _getDefaultStandards();
      } else {
        print('Error loading standards: $e');
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  List<Standard> _getDefaultStandards() {
    return [
      Standard(id: 1, name: '5th', displayOrder: 0),
      Standard(id: 2, name: '6th', displayOrder: 1),
      Standard(id: 3, name: '7th', displayOrder: 2),
      Standard(id: 4, name: '8th', displayOrder: 3),
      Standard(id: 5, name: '9th', displayOrder: 4),
      Standard(id: 6, name: '10th', displayOrder: 5),
      Standard(id: 7, name: 'Abacus', displayOrder: 6),
    ];
  }

  Future<void> addStandard(Standard standard) async {
    await _databaseService.insertStandard(standard);
    await loadStandards();
  }

  Future<void> updateStandard(Standard standard) async {
    await _databaseService.updateStandard(standard);
    await loadStandards();
  }

  Future<void> deleteStandard(int id) async {
    await _databaseService.deleteStandard(id);
    await loadStandards();
  }

  Future<void> reorderStandards(List<Standard> reorderedList) async {
    for (int i = 0; i < reorderedList.length; i++) {
      reorderedList[i].displayOrder = i;
      await _databaseService.updateStandard(reorderedList[i]);
    }
    _standards = reorderedList;
    notifyListeners();
  }
}
