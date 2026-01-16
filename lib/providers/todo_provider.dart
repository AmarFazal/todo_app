import 'package:flutter/foundation.dart';
import '../models/todo_model.dart';
import '../database/database_helper.dart';

class TodoProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<TodoModel> _todos = [];
  bool _isLoading = false;

  List<TodoModel> get todos => _todos;
  bool get isLoading => _isLoading;

  Future<void> loadTodos() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _todos = await _db.getAllTodos();
    } catch (e) {
      debugPrint('Error loading todos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTodo(TodoModel todo) async {
    try {
      await _db.createTodo(todo);
      await loadTodos();
    } catch (e) {
      debugPrint('Error adding todo: $e');
    }
  }

  Future<void> updateTodo(TodoModel todo) async {
    try {
      await _db.updateTodo(todo);
      await loadTodos();
    } catch (e) {
      debugPrint('Error updating todo: $e');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _db.deleteTodo(id);
      await loadTodos();
    } catch (e) {
      debugPrint('Error deleting todo: $e');
    }
  }

  Future<void> toggleTodo(String id) async {
    try {
      final todo = await _db.getTodo(id);
      if (todo != null) {
        await _db.updateTodo(todo.copyWith(isCompleted: !todo.isCompleted));
        await loadTodos();
      }
    } catch (e) {
      debugPrint('Error toggling todo: $e');
    }
  }

  List<TodoModel> getTodayTodos() {
    final today = DateTime.now();
    return _todos.where((todo) {
      if (todo.dueDate == null) return false;
      final dueDate = todo.dueDate!;
      return dueDate.year == today.year &&
          dueDate.month == today.month &&
          dueDate.day == today.day;
    }).toList();
  }

  List<TodoModel> getCompletedTodos() {
    return _todos.where((todo) => todo.isCompleted).toList();
  }

  List<TodoModel> getPendingTodos() {
    return _todos.where((todo) => !todo.isCompleted).toList();
  }
}

