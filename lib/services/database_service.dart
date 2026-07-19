import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

final List<Map<String, Object?>> _defaultStandardsSeed = [
  {'name': '5th', 'display_order': 0},
  {'name': '6th', 'display_order': 1},
  {'name': '7th', 'display_order': 2},
  {'name': '8th', 'display_order': 3},
  {'name': '9th', 'display_order': 4},
  {'name': '10th', 'display_order': 5},
  {'name': 'Abacus', 'display_order': 6},
];

final List<Map<String, Object?>> _defaultSubjectsSeed = [
  {'name': '--', 'display_order': null},
  {'name': 'Abacus', 'display_order': null},
  {'name': 'Parents meet', 'display_order': null},
  {'name': 'Hindi/Sanskrit', 'display_order': null},
  {'name': 'Maths - 1', 'display_order': null},
  {'name': 'Maths - 2', 'display_order': null},
  {'name': 'Science - 1', 'display_order': null},
  {'name': 'Science - 2', 'display_order': null},
  {'name': 'Doubt clearing session - Maths', 'display_order': null},
  {'name': 'Doubt clearing session - English (Ar)', 'display_order': null},
  {'name': 'Doubt clearing session - Science', 'display_order': null},
  {'name': 'Doubt clearing session - English (An)', 'display_order': null},
  {'name': 'Maths', 'display_order': 0},
  {'name': 'Maths (Sn)', 'display_order': 1},
  {'name': 'Science', 'display_order': 2},
  {'name': 'Science (Sn)', 'display_order': 3},
  {'name': 'English (Ar)', 'display_order': 4},
  {'name': 'English (An)', 'display_order': 5},
  {'name': 'English (Sn)', 'display_order': 6},
  {'name': 'English (N)', 'display_order': 7},
  {'name': 'Sanskrit', 'display_order': 8},
  {'name': 'Marathi', 'display_order': 9},
  {'name': 'SST (An)', 'display_order': 10},
  {'name': 'SST (N)', 'display_order': 11},
  {'name': 'Hindi (Sn)', 'display_order': 12},
  {'name': 'Hindi (An)', 'display_order': 13},
  {'name': 'Geography (N)', 'display_order': 14},
  {'name': 'Geography (An)', 'display_order': 15},
  {'name': 'Exam', 'display_order': 16},
  {'name': 'Holiday', 'display_order': 17},
];

final List<Map<String, Object?>> _defaultTimeSlotsSeed = [
  {'time': '10.00 AM', 'display_order': null},
  {'time': '11.00 AM', 'display_order': null},
  {'time': '11.30 AM', 'display_order': null},
  {'time': '01.00 PM', 'display_order': null},
  {'time': '06:45 AM', 'display_order': 0},
  {'time': '07:30 AM', 'display_order': 1},
  {'time': '08:15 AM', 'display_order': 2},
  {'time': '09:00 AM', 'display_order': 3},
  {'time': '09:45 AM', 'display_order': 4},
  {'time': '10:30 AM', 'display_order': 5},
  {'time': '11:15 AM', 'display_order': 6},
  {'time': '12:00 PM', 'display_order': 7},
  {'time': '12:45 PM', 'display_order': 8},
  {'time': '01:30 PM', 'display_order': 9},
  {'time': '02:15 PM', 'display_order': 10},
  {'time': '03:00 PM', 'display_order': 11},
  {'time': '03:45 PM', 'display_order': 12},
  {'time': '04:30 PM', 'display_order': 13},
  {'time': '05:15 PM', 'display_order': 14},
  {'time': '06:00 PM', 'display_order': 15},
  {'time': '06:45 PM', 'display_order': 16},
  {'time': '07:30 PM', 'display_order': 17},
  {'time': '08:15 PM', 'display_order': 18},
  {'time': '09:00 PM', 'display_order': 19},
];

final List<Map<String, Object?>> _defaultTimetablesSeed = [
  {
    'seed_key': 0,
    'standard': '10th, 9th, 8th, 7th, 6th',
    'date': '2026-07-18T12:46:25.232551',
    'academy_name': 'VidyaNiketan Classes and Academy',
    'created_at': '2026-07-18T12:47:26.471607',
    'updated_at': '2026-07-18T13:04:55.344287'
  },
  {
    'seed_key': 1,
    'standard': '10th, 9th, 8th, 7th, 6th, Abacus',
    'date': '2026-07-19T00:00:00.000',
    'academy_name': 'VidyaNiketan Classes and Academy',
    'created_at': '2026-07-18T18:40:24.375334',
    'updated_at': '2026-07-18T19:02:33.315546'
  },
  {
    'seed_key': 2,
    'standard': '10th, 9th, 8th, 7th, 6th',
    'date': '2026-07-20T00:00:00.000',
    'academy_name': 'VidyaNiketan Classes and Academy',
    'created_at': '2026-07-19T20:06:46.046279',
    'updated_at': '2026-07-19T20:31:44.723530'
  },
];

final List<Map<String, Object?>> _defaultTimetableRowsSeed = [
  {
    'seed_timetable_key': 0,
    'from_time': '06:45 AM',
    'to_time': '07:30 AM',
    'subject': '10th|||English (Ar)'
  },
  {
    'seed_timetable_key': 0,
    'from_time': '06:45 AM',
    'to_time': '07:30 AM',
    'subject': '9th|||Hindi (Sn)'
  },
  {'seed_timetable_key': 0, 'from_time': '06:45 AM', 'to_time': '07:30 AM', 'subject': '8th|||'},
  {'seed_timetable_key': 0, 'from_time': '06:45 AM', 'to_time': '07:30 AM', 'subject': '7th|||'},
  {'seed_timetable_key': 0, 'from_time': '06:45 AM', 'to_time': '07:30 AM', 'subject': '6th|||'},
  {
    'seed_timetable_key': 0,
    'from_time': '07:30 AM',
    'to_time': '08:15 AM',
    'subject': '10th|||Hindi (Sn)'
  },
  {
    'seed_timetable_key': 0,
    'from_time': '07:30 AM',
    'to_time': '08:15 AM',
    'subject': '9th|||English (Ar)'
  },
  {'seed_timetable_key': 0, 'from_time': '07:30 AM', 'to_time': '08:15 AM', 'subject': '8th|||'},
  {'seed_timetable_key': 0, 'from_time': '07:30 AM', 'to_time': '08:15 AM', 'subject': '7th|||'},
  {'seed_timetable_key': 0, 'from_time': '07:30 AM', 'to_time': '08:15 AM', 'subject': '6th|||'},
  {
    'seed_timetable_key': 0,
    'from_time': '08:15 AM',
    'to_time': '09:00 AM',
    'subject': '10th|||Science'
  },
  {'seed_timetable_key': 0, 'from_time': '08:15 AM', 'to_time': '09:00 AM', 'subject': '9th|||Maths'},
  {
    'seed_timetable_key': 0,
    'from_time': '08:15 AM',
    'to_time': '09:00 AM',
    'subject': '8th|||English (Ar)'
  },
  {
    'seed_timetable_key': 0,
    'from_time': '08:15 AM',
    'to_time': '09:00 AM',
    'subject': '7th|||Science (Sn)'
  },
  {'seed_timetable_key': 0, 'from_time': '08:15 AM', 'to_time': '09:00 AM', 'subject': '6th|||Marathi'},
  {'seed_timetable_key': 0, 'from_time': '09:00 AM', 'to_time': '09:45 AM', 'subject': '10th|||'},
  {'seed_timetable_key': 0, 'from_time': '09:00 AM', 'to_time': '09:45 AM', 'subject': '9th|||'},
  {
    'seed_timetable_key': 0,
    'from_time': '09:00 AM',
    'to_time': '09:45 AM',
    'subject': '8th|||Science'
  },
  {'seed_timetable_key': 0, 'from_time': '09:00 AM', 'to_time': '09:45 AM', 'subject': '7th|||Marathi'},
  {
    'seed_timetable_key': 0,
    'from_time': '09:00 AM',
    'to_time': '09:45 AM',
    'subject': '6th|||Science (Sn)'
  },
  {'seed_timetable_key': 1, 'from_time': '09:00 AM', 'to_time': '10.00 AM', 'subject': '10th|||Exam'},
  {'seed_timetable_key': 1, 'from_time': '09:00 AM', 'to_time': '10.00 AM', 'subject': '9th|||Exam'},
  {'seed_timetable_key': 1, 'from_time': '09:00 AM', 'to_time': '10.00 AM', 'subject': '8th|||Exam'},
  {
    'seed_timetable_key': 1,
    'from_time': '09:00 AM',
    'to_time': '10.00 AM',
    'subject': '7th|||Hindi (Sn)'
  },
  {
    'seed_timetable_key': 1,
    'from_time': '09:00 AM',
    'to_time': '10.00 AM',
    'subject': '6th|||Hindi (Sn)'
  },
  {'seed_timetable_key': 1, 'from_time': '09:00 AM', 'to_time': '10.00 AM', 'subject': 'Abacus|||--'},
  {'seed_timetable_key': 1, 'from_time': '10.00 AM', 'to_time': '11.00 AM', 'subject': '10th|||Exam'},
  {'seed_timetable_key': 1, 'from_time': '10.00 AM', 'to_time': '11.00 AM', 'subject': '9th|||Exam'},
  {'seed_timetable_key': 1, 'from_time': '10.00 AM', 'to_time': '11.00 AM', 'subject': '8th|||Exam'},
  {
    'seed_timetable_key': 1,
    'from_time': '10.00 AM',
    'to_time': '11.00 AM',
    'subject': '7th|||English (Ar)'
  },
  {
    'seed_timetable_key': 1,
    'from_time': '10.00 AM',
    'to_time': '11.00 AM',
    'subject': '6th|||English (Ar)'
  },
  {'seed_timetable_key': 1, 'from_time': '10.00 AM', 'to_time': '11.00 AM', 'subject': 'Abacus|||Abacus'},
  {
    'seed_timetable_key': 1,
    'from_time': '11.00 AM',
    'to_time': '12:00 PM',
    'subject': '10th|||Parents meet'
  },
  {'seed_timetable_key': 1, 'from_time': '11.00 AM', 'to_time': '12:00 PM', 'subject': '9th|||--'},
  {'seed_timetable_key': 1, 'from_time': '11.00 AM', 'to_time': '12:00 PM', 'subject': '8th|||--'},
  {'seed_timetable_key': 1, 'from_time': '11.00 AM', 'to_time': '12:00 PM', 'subject': '7th|||--'},
  {'seed_timetable_key': 1, 'from_time': '11.00 AM', 'to_time': '12:00 PM', 'subject': '6th|||--'},
  {'seed_timetable_key': 1, 'from_time': '11.00 AM', 'to_time': '12:00 PM', 'subject': 'Abacus|||--'},
  {
    'seed_timetable_key': 2,
    'from_time': '06:45 AM',
    'to_time': '07:30 AM',
    'subject': '10th|||English (Ar)'
  },
  {
    'seed_timetable_key': 2,
    'from_time': '06:45 AM',
    'to_time': '07:30 AM',
    'subject': '9th|||Hindi/Sanskrit'
  },
  {'seed_timetable_key': 2, 'from_time': '06:45 AM', 'to_time': '07:30 AM', 'subject': '8th|||'},
  {'seed_timetable_key': 2, 'from_time': '06:45 AM', 'to_time': '07:30 AM', 'subject': '7th|||'},
  {'seed_timetable_key': 2, 'from_time': '06:45 AM', 'to_time': '07:30 AM', 'subject': '6th|||'},
  {
    'seed_timetable_key': 2,
    'from_time': '07:30 AM',
    'to_time': '08:15 AM',
    'subject': '10th|||Hindi/Sanskrit'
  },
  {
    'seed_timetable_key': 2,
    'from_time': '07:30 AM',
    'to_time': '08:15 AM',
    'subject': '9th|||English (Ar)'
  },
  {'seed_timetable_key': 2, 'from_time': '07:30 AM', 'to_time': '08:15 AM', 'subject': '8th|||'},
  {'seed_timetable_key': 2, 'from_time': '07:30 AM', 'to_time': '08:15 AM', 'subject': '7th|||'},
  {'seed_timetable_key': 2, 'from_time': '07:30 AM', 'to_time': '08:15 AM', 'subject': '6th|||'},
  {
    'seed_timetable_key': 2,
    'from_time': '08:15 AM',
    'to_time': '09:00 AM',
    'subject': '10th|||Science - 2'
  },
  {'seed_timetable_key': 2, 'from_time': '08:15 AM', 'to_time': '09:00 AM', 'subject': '9th|||Maths - 2'},
  {
    'seed_timetable_key': 2,
    'from_time': '08:15 AM',
    'to_time': '09:00 AM',
    'subject': '8th|||English (Ar)'
  },
  {
    'seed_timetable_key': 2,
    'from_time': '08:15 AM',
    'to_time': '09:00 AM',
    'subject': '7th|||Science (Sn)'
  },
  {'seed_timetable_key': 2, 'from_time': '08:15 AM', 'to_time': '09:00 AM', 'subject': '6th|||Marathi'},
  {
    'seed_timetable_key': 2,
    'from_time': '09:00 AM',
    'to_time': '09:45 AM',
    'subject': '10th|||Doubt clearing session - Maths'
  },
  {
    'seed_timetable_key': 2,
    'from_time': '09:00 AM',
    'to_time': '09:45 AM',
    'subject': '9th|||Doubt clearing session - English (Ar)'
  },
  {'seed_timetable_key': 2, 'from_time': '09:00 AM', 'to_time': '09:45 AM', 'subject': '8th|||Science'},
  {'seed_timetable_key': 2, 'from_time': '09:00 AM', 'to_time': '09:45 AM', 'subject': '7th|||Marathi'},
  {
    'seed_timetable_key': 2,
    'from_time': '09:00 AM',
    'to_time': '09:45 AM',
    'subject': '6th|||Science (Sn)'
  },
];

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
    // Insert default timetables and rows
    await _insertDefaultTimetables(db);
  }

  Future<void> _insertDefaultStandards(Database db) async {
    for (final standard in _defaultStandardsSeed) {
      await db.insert('standards', {
        'name': standard['name'] as String,
        'display_order': standard['display_order'],
      });
    }
  }

  Future<void> _insertDefaultSubjects(Database db) async {
    for (final subject in _defaultSubjectsSeed) {
      await db.insert('subjects', {
        'name': subject['name'] as String,
        'display_order': subject['display_order'],
      });
    }
  }

  Future<void> _insertDefaultTimeSlots(Database db) async {
    for (final slot in _defaultTimeSlotsSeed) {
      await db.insert('time_slots', {
        'time': slot['time'] as String,
        'display_order': slot['display_order'],
      });
    }
  }

  Future<void> _insertDefaultTimetables(Database db) async {
    final insertedIdsBySeedKey = <int, int>{};

    for (final timetable in _defaultTimetablesSeed) {
      final insertedId = await db.insert('timetables', {
        'standard': timetable['standard'] as String,
        'date': timetable['date'] as String,
        'academy_name': timetable['academy_name'] as String,
        'created_at': timetable['created_at'] as String,
        'updated_at': timetable['updated_at'] as String,
      });
      insertedIdsBySeedKey[timetable['seed_key'] as int] = insertedId;
    }

    for (final row in _defaultTimetableRowsSeed) {
      final seedKey = row['seed_timetable_key'] as int;
      final timetableId = insertedIdsBySeedKey[seedKey];
      if (timetableId == null) {
        continue;
      }

      await db.insert('timetable_rows', {
        'timetable_id': timetableId,
        'from_time': row['from_time'] as String,
        'to_time': row['to_time'] as String,
        'subject': row['subject'] as String,
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
