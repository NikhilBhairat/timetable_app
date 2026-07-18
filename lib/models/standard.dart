class Standard {
  int? id;
  String name;
  int? displayOrder;

  Standard({
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

  factory Standard.fromMap(Map<String, dynamic> map) {
    return Standard(
      id: map['id'],
      name: map['name'],
      displayOrder: map['display_order'],
    );
  }

  Standard copyWith({
    int? id,
    String? name,
    int? displayOrder,
  }) {
    return Standard(
      id: id ?? this.id,
      name: name ?? this.name,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }
}
