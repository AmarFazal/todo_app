class HabitModel {
  final String id;
  final String title;
  final String? description;
  final String categoryId;
  final DateTime createdAt;
  final int targetDays; // Weekly target (e.g., 5 days per week)
  final List<int> completedDays; // List of day numbers (0-6, Monday-Sunday)
  final Map<String, bool> weeklyProgress; // Map of date strings to completion status
  final String? reminderTime;
  final int streak; // Current streak count
  final int longestStreak; // Longest streak achieved
  final String color; // Hex color code

  HabitModel({
    required this.id,
    required this.title,
    this.description,
    required this.categoryId,
    required this.createdAt,
    this.targetDays = 5,
    this.completedDays = const [],
    Map<String, bool>? weeklyProgress,
    this.reminderTime,
    this.streak = 0,
    this.longestStreak = 0,
    this.color = '#6366F1',
  }) : weeklyProgress = weeklyProgress ?? {};

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'targetDays': targetDays,
      'completedDays': completedDays.join(','),
      'weeklyProgress': weeklyProgress.entries
          .map((e) => '${e.key}:${e.value}')
          .join('|'),
      'reminderTime': reminderTime,
      'streak': streak,
      'longestStreak': longestStreak,
      'color': color,
    };
  }

  factory HabitModel.fromMap(Map<String, dynamic> map) {
    final completedDaysStr = map['completedDays'] as String? ?? '';
    final weeklyProgressStr = map['weeklyProgress'] as String? ?? '';
    
    return HabitModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      categoryId: map['categoryId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      targetDays: map['targetDays'] as int? ?? 5,
      completedDays: completedDaysStr.isEmpty
          ? []
          : completedDaysStr.split(',').map((e) => int.parse(e)).toList(),
      weeklyProgress: weeklyProgressStr.isEmpty
          ? {}
          : Map.fromEntries(
              weeklyProgressStr.split('|').map((e) {
                final parts = e.split(':');
                return MapEntry(parts[0], parts[1] == 'true');
              }),
            ),
      reminderTime: map['reminderTime'] as String?,
      streak: map['streak'] as int? ?? 0,
      longestStreak: map['longestStreak'] as int? ?? 0,
      color: map['color'] as String? ?? '#6366F1',
    );
  }

  HabitModel copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    DateTime? createdAt,
    int? targetDays,
    List<int>? completedDays,
    Map<String, bool>? weeklyProgress,
    String? reminderTime,
    int? streak,
    int? longestStreak,
    String? color,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      targetDays: targetDays ?? this.targetDays,
      completedDays: completedDays ?? this.completedDays,
      weeklyProgress: weeklyProgress ?? this.weeklyProgress,
      reminderTime: reminderTime ?? this.reminderTime,
      streak: streak ?? this.streak,
      longestStreak: longestStreak ?? this.longestStreak,
      color: color ?? this.color,
    );
  }

  bool isCompletedToday() {
    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    return weeklyProgress[todayKey] ?? false;
  }

  int getWeekProgress() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    int completed = 0;
    
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      final dateKey = '${date.year}-${date.month}-${date.day}';
      if (weeklyProgress[dateKey] == true) {
        completed++;
      }
    }
    
    return completed;
  }
}

