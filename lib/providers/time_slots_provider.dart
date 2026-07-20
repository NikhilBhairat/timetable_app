import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class TimeSlotsProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<TimeSlot> _timeSlots = [];
  bool _isLoading = false;

  List<TimeSlot> get timeSlots => _timeSlots;
  bool get isLoading => _isLoading;

  Future<void> loadTimeSlots() async {
    _isLoading = true;
    notifyListeners();
    try {
      _timeSlots = await _databaseService.getAllTimeSlots();
    } catch (e) {
      if (e is UnsupportedError) {
        print('Database not supported on this platform: $e');
        // Provide default time slots for web
        _timeSlots = _getDefaultTimeSlots();
      } else {
        print('Error loading time slots: $e');
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  List<TimeSlot> _getDefaultTimeSlots() {
    const startMinutes = 6 * 60 + 45; // 06:45 AM
    const endMinutes = 20 * 60 + 30; // 08:30 PM

    final defaults = <String>[];
    for (var totalMinutes = startMinutes; totalMinutes <= endMinutes; totalMinutes += 15) {
      final hour24 = totalMinutes ~/ 60;
      final minute = totalMinutes % 60;
      final period = hour24 >= 12 ? 'PM' : 'AM';
      final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
      final minuteLabel = minute.toString().padLeft(2, '0');
      defaults.add('${hour12.toString().padLeft(2, '0')}:$minuteLabel $period');
    }

    return List.generate(defaults.length, (i) => TimeSlot(id: i + 1, time: defaults[i], displayOrder: i));
  }

  Future<void> addTimeSlot(TimeSlot slot) async {
    await _databaseService.insertTimeSlot(slot);
    await loadTimeSlots();
  }

  Future<void> updateTimeSlot(TimeSlot slot) async {
    await _databaseService.updateTimeSlot(slot);
    await loadTimeSlots();
  }

  Future<void> deleteTimeSlot(int id) async {
    await _databaseService.deleteTimeSlot(id);
    await loadTimeSlots();
  }

  Future<void> reorderTimeSlots(List<TimeSlot> reorderedList) async {
    for (int i = 0; i < reorderedList.length; i++) {
      reorderedList[i].displayOrder = i;
      await _databaseService.updateTimeSlot(reorderedList[i]);
    }
    _timeSlots = reorderedList;
    notifyListeners();
  }
}
