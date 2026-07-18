class TimeSlot {
  int? id;
  String time; // e.g., "06:45 AM"
  int? displayOrder;

  TimeSlot({
    this.id,
    required this.time,
    this.displayOrder,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': time,
      'display_order': displayOrder,
    };
  }

  factory TimeSlot.fromMap(Map<String, dynamic> map) {
    return TimeSlot(
      id: map['id'],
      time: map['time'],
      displayOrder: map['display_order'],
    );
  }

  TimeSlot copyWith({
    int? id,
    String? time,
    int? displayOrder,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      time: time ?? this.time,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }
}
