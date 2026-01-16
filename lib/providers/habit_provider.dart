import 'package:flutter/foundation.dart';
import '../models/habit_model.dart';
import '../database/database_helper.dart';

class HabitProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<HabitModel> _habits = [];
  bool _isLoading = false;

  List<HabitModel> get habits => _habits;
  bool get isLoading => _isLoading;

  Future<void> loadHabits() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _habits = await _db.getAllHabits();
    } catch (e) {
      debugPrint('Error loading habits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addHabit(HabitModel habit) async {
    try {
      await _db.createHabit(habit);
      await loadHabits();
    } catch (e) {
      debugPrint('Error adding habit: $e');
    }
  }

  Future<void> updateHabit(HabitModel habit) async {
    try {
      await _db.updateHabit(habit);
      await loadHabits();
    } catch (e) {
      debugPrint('Error updating habit: $e');
    }
  }

  Future<void> deleteHabit(String id) async {
    try {
      await _db.deleteHabit(id);
      await loadHabits();
    } catch (e) {
      debugPrint('Error deleting habit: $e');
    }
  }

  Future<void> toggleHabitToday(String id) async {
    try {
      final habit = await _db.getHabit(id);
      if (habit != null) {
        final today = DateTime.now();
        final todayKey = '${today.year}-${today.month}-${today.day}';
        final isCompleted = habit.isCompletedToday();
        
        final updatedProgress = Map<String, bool>.from(habit.weeklyProgress);
        updatedProgress[todayKey] = !isCompleted;
        
        // Calculate streak
        int newStreak = habit.streak;
        if (!isCompleted) {
          // Marking as complete
          final yesterday = today.subtract(const Duration(days: 1));
          final yesterdayKey = '${yesterday.year}-${yesterday.month}-${yesterday.day}';
          
          if (updatedProgress[yesterdayKey] == true || habit.streak == 0) {
            newStreak = habit.streak + 1;
          } else {
            newStreak = 1;
          }
        } else {
          // Unmarking - reset streak if breaking it
          newStreak = 0;
        }
        
        final longestStreak = newStreak > habit.longestStreak
            ? newStreak
            : habit.longestStreak;
        
        await _db.updateHabit(habit.copyWith(
          weeklyProgress: updatedProgress,
          streak: newStreak,
          longestStreak: longestStreak,
        ));
        await loadHabits();
      }
    } catch (e) {
      debugPrint('Error toggling habit: $e');
    }
  }
}

