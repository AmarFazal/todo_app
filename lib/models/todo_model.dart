class TodoModel {
  final String id;
  final String title;
  final String? description;
  final String categoryId;
  final DateTime createdAt;
  final DateTime? dueDate;
  final bool isCompleted;
  final int priority; // 0: Low, 1: Medium, 2: High
  final String? reminderTime;

  TodoModel({
    required this.id,
    required this.title,
    this.description,
    required this.categoryId,
    required this.createdAt,
    this.dueDate,
    this.isCompleted = false,
    this.priority = 1,
    this.reminderTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'priority': priority,
      'reminderTime': reminderTime,
    };
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      categoryId: map['categoryId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      isCompleted: (map['isCompleted'] as int) == 1,
      priority: map['priority'] as int,
      reminderTime: map['reminderTime'] as String?,
    );
  }

  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    DateTime? createdAt,
    DateTime? dueDate,
    bool? isCompleted,
    int? priority,
    String? reminderTime,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}

