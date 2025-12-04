class Tag {
  final String id;
  final String name;
  final String? parentId;
  final String? color;
  final DateTime createdAt;
  List<Tag>? children;

  Tag({
    required this.id,
    required this.name,
    this.parentId,
    this.color,
    required this.createdAt,
    this.children,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'color': color,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'],
      name: map['name'],
      parentId: map['parent_id'],
      color: map['color'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Tag copyWith({
    String? id,
    String? name,
    String? parentId,
    String? color,
    DateTime? createdAt,
    List<Tag>? children,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      children: children ?? this.children,
    );
  }
}
