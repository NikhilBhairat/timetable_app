import 'timetable_row.dart';

class Timetable {
  int? id;
  String standard;
  DateTime date;
  String? academyName;
  List<TimetableRow> rows;
  DateTime createdAt;
  DateTime updatedAt;

  Timetable({
    this.id,
    required this.standard,
    required this.date,
    this.academyName,
    required this.rows,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'standard': standard,
      'date': date.toIso8601String(),
      'academy_name': academyName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Timetable.fromMap(Map<String, dynamic> map) {
    return Timetable(
      id: map['id'],
      standard: map['standard'],
      date: DateTime.parse(map['date']),
      academyName: map['academy_name'],
      rows: [],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Timetable copyWith({
    int? id,
    String? standard,
    DateTime? date,
    String? academyName,
    List<TimetableRow>? rows,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Timetable(
      id: id ?? this.id,
      standard: standard ?? this.standard,
      date: date ?? this.date,
      academyName: academyName ?? this.academyName,
      rows: rows ?? this.rows,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
