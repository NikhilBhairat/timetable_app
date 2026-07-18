class TimetableRow {
  int? id;
  String fromTime;
  String toTime;
  String subject;

  TimetableRow({
    this.id,
    required this.fromTime,
    required this.toTime,
    required this.subject,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'from_time': fromTime,
      'to_time': toTime,
      'subject': subject,
    };
  }

  factory TimetableRow.fromMap(Map<String, dynamic> map) {
    return TimetableRow(
      id: map['id'],
      fromTime: map['from_time'],
      toTime: map['to_time'],
      subject: map['subject'],
    );
  }

  TimetableRow copyWith({
    int? id,
    String? fromTime,
    String? toTime,
    String? subject,
  }) {
    return TimetableRow(
      id: id ?? this.id,
      fromTime: fromTime ?? this.fromTime,
      toTime: toTime ?? this.toTime,
      subject: subject ?? this.subject,
    );
  }
}
