import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  static bool _databaseFactoryConfigured = false;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on web. Use a web-compatible storage solution.');
    }
    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    if (!kIsWeb &&
        !_databaseFactoryConfigured &&
        (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.linux)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      _databaseFactoryConfigured = true;
    }

    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'timetable_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Timetables table
    await db.execute('''
      CREATE TABLE timetables (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        standard TEXT NOT NULL,
        date TEXT NOT NULL,
        academy_name TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Timetable rows table
    await db.execute('''
      CREATE TABLE timetable_rows (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timetable_id INTEGER NOT NULL,
        from_time TEXT NOT NULL,
        to_time TEXT NOT NULL,
        subject TEXT NOT NULL,
        FOREIGN KEY (timetable_id) REFERENCES timetables(id) ON DELETE CASCADE
      )
    ''');

    // Standards table
    await db.execute('''
      CREATE TABLE standards (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        display_order INTEGER
      )
    ''');

    // Subjects table
    await db.execute('''
      CREATE TABLE subjects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        display_order INTEGER
      )
    ''');

    // Time slots table
    await db.execute('''
      CREATE TABLE time_slots (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        time TEXT NOT NULL UNIQUE,
        display_order INTEGER
      )
    ''');

    // Insert default standards
    await _insertDefaultStandards(db);
    // Insert default subjects
    await _insertDefaultSubjects(db);
    // Insert default time slots
    await _insertDefaultTimeSlots(db);
  }

  Future<void> _insertDefaultStandards(Database db) async {
    final defaults = [
      '5th', '6th', '7th', '8th', '9th', '10th', 'Abacus'
    ];
    for (int i = 0; i < defaults.length; i++) {
      await db.insert('standards', {
        'name': defaults[i],
        'display_order': i,
      });
    }
  }

  Future<void> _insertDefaultSubjects(Database db) async {
    final defaults = [
      'Maths', 'Maths (Sn)', 'Science', 'Science (Sn)',
      'English (Ar)', 'English (An)', 'English (Sn)', 'English (N)',
      'Sanskrit', 'Marathi', 'SST (An)', 'SST (N)',
      'Hindi (Sn)', 'Hindi (An)', 'Geography (N)', 'Geography (An)',
      'Exam', 'Holiday'
    ];
    for (int i = 0; i < defaults.length; i++) {
      await db.insert('subjects', {
        'name': defaults[i],
        'display_order': i,
      });
    }
  }

  Future<void> _insertDefaultTimeSlots(Database db) async {
    final defaults = [
      '06:45 AM', '07:30 AM', '08:15 AM', '09:00 AM', '09:45 AM',
      '10:30 AM', '11:15 AM', '12:00 PM', '12:45 PM', '01:30 PM',
      '02:15 PM', '03:00 PM', '03:45 PM', '04:30 PM', '05:15 PM',
      '06:00 PM', '06:45 PM', '07:30 PM', '08:15 PM', '09:00 PM'
    ];
    for (int i = 0; i < defaults.length; i++) {
      await db.insert('time_slots', {
        'time': defaults[i],
        'display_order': i,
      });
    }
  }

  // Timetable operations
  Future<int> insertTimetable(Timetable timetable) async {
    final db = await database;
    return await db.insert('timetables', timetable.toMap());
  }

  Future<int> updateTimetable(Timetable timetable) async {
    final db = await database;
    return await db.update(
      'timetables',
      timetable.toMap(),
      where: 'id = ?',
      whereArgs: [timetable.id],
    );
  }

  Future<int> deleteTimetable(int id) async {
    final db = await database;
    return await db.delete('timetables', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Timetable>> getAllTimetables() async {
    final db = await database;
    final maps = await db.query('timetables', orderBy: 'date DESC');
    return List.generate(maps.length, (i) {
      return Timetable.fromMap(maps[i]);
    });
  }

  Future<Timetable?> getTimetableById(int id) async {
    final db = await database;
    final maps = await db.query(
      'timetables',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Timetable.fromMap(maps.first);
    }
    return null;
  }

  // Timetable rows operations
  Future<int> insertTimetableRow(int timetableId, TimetableRow row) async {
    final db = await database;
    return await db.insert('timetable_rows', {
      'timetable_id': timetableId,
      ...row.toMap(),
    });
  }

  Future<int> updateTimetableRow(TimetableRow row) async {
    final db = await database;
    return await db.update(
      'timetable_rows',
      row.toMap(),
      where: 'id = ?',
      whereArgs: [row.id],
    );
  }

  Future<int> deleteTimetableRow(int rowId) async {
    final db = await database;
    return await db.delete('timetable_rows', where: 'id = ?', whereArgs: [rowId]);
  }

  Future<List<TimetableRow>> getTimetableRows(int timetableId) async {
    final db = await database;
    final maps = await db.query(
      'timetable_rows',
      where: 'timetable_id = ?',
      whereArgs: [timetableId],
    );
    return List.generate(maps.length, (i) => TimetableRow.fromMap(maps[i]));
  }

  // Standards operations
  Future<int> insertStandard(Standard standard) async {
    final db = await database;
    return await db.insert('standards', standard.toMap());
  }

  Future<int> updateStandard(Standard standard) async {
    final db = await database;
    return await db.update(
      'standards',
      standard.toMap(),
      where: 'id = ?',
      whereArgs: [standard.id],
    );
  }

  Future<int> deleteStandard(int id) async {
    final db = await database;
    return await db.delete('standards', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Standard>> getAllStandards() async {
    final db = await database;
    final maps = await db.query('standards', orderBy: 'display_order');
    return List.generate(maps.length, (i) => Standard.fromMap(maps[i]));
  }

  // Subjects operations
  Future<int> insertSubject(Subject subject) async {
    final db = await database;
    return await db.insert('subjects', subject.toMap());
  }

  Future<int> updateSubject(Subject subject) async {
    final db = await database;
    return await db.update(
      'subjects',
      subject.toMap(),
      where: 'id = ?',
      whereArgs: [subject.id],
    );
  }

  Future<int> deleteSubject(int id) async {
    final db = await database;
    return await db.delete('subjects', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Subject>> getAllSubjects() async {
    final db = await database;
    final maps = await db.query('subjects', orderBy: 'display_order');
    return List.generate(maps.length, (i) => Subject.fromMap(maps[i]));
  }

  // Time slots operations
  Future<int> insertTimeSlot(TimeSlot slot) async {
    final db = await database;
    return await db.insert('time_slots', slot.toMap());
  }

  Future<int> updateTimeSlot(TimeSlot slot) async {
    final db = await database;
    return await db.update(
      'time_slots',
      slot.toMap(),
      where: 'id = ?',
      whereArgs: [slot.id],
    );
  }

  Future<int> deleteTimeSlot(int id) async {
    final db = await database;
    return await db.delete('time_slots', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TimeSlot>> getAllTimeSlots() async {
    final db = await database;
    final maps = await db.query('time_slots', orderBy: 'display_order');
    return List.generate(maps.length, (i) => TimeSlot.fromMap(maps[i]));
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
