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
    final defaults = [
      '06:45 AM', '07:30 AM', '08:15 AM', '09:00 AM', '09:45 AM',
      '10:30 AM', '11:15 AM', '12:00 PM', '12:45 PM', '01:30 PM',
      '02:15 PM', '03:00 PM', '03:45 PM', '04:30 PM', '05:15 PM',
      '06:00 PM', '06:45 PM', '07:30 PM', '08:15 PM', '09:00 PM'
    ];
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
