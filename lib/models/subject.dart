class Subject {
  int? id;
  String name;
  int? displayOrder;

  Subject({
    this.id,
    required this.name,
    this.displayOrder,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'display_order': displayOrder,
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      id: map['id'],
      name: map['name'],
      displayOrder: map['display_order'],
    );
  }

  Subject copyWith({
    int? id,
    String? name,
    int? displayOrder,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }
}
