import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo_model.dart';
import '../models/habit_model.dart';
import '../models/category_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('todo_habit.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Categories table
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        color TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    // Todos table
    await db.execute('''
      CREATE TABLE todos (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        categoryId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        dueDate TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        priority INTEGER NOT NULL DEFAULT 1,
        reminderTime TEXT,
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    // Habits table
    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        categoryId TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        targetDays INTEGER NOT NULL DEFAULT 5,
        completedDays TEXT,
        weeklyProgress TEXT,
        reminderTime TEXT,
        streak INTEGER NOT NULL DEFAULT 0,
        longestStreak INTEGER NOT NULL DEFAULT 0,
        color TEXT NOT NULL DEFAULT '#6366F1',
        FOREIGN KEY (categoryId) REFERENCES categories (id)
      )
    ''');

    // Create default categories
    final defaultCategories = [
      CategoryModel(
        id: 'cat_work',
        name: 'Work',
        icon: '💼',
        color: '#3B82F6',
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: 'cat_personal',
        name: 'Personal',
        icon: '👤',
        color: '#10B981',
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: 'cat_health',
        name: 'Health',
        icon: '💪',
        color: '#EF4444',
        createdAt: DateTime.now(),
      ),
      CategoryModel(
        id: 'cat_learning',
        name: 'Learning',
        icon: '📚',
        color: '#8B5CF6',
        createdAt: DateTime.now(),
      ),
    ];

    for (var category in defaultCategories) {
      await db.insert('categories', category.toMap());
    }
  }

  // Category CRUD
  Future<String> createCategory(CategoryModel category) async {
    final db = await database;
    await db.insert('categories', category.toMap());
    return category.id;
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await database;
    final result = await db.query('categories', orderBy: 'createdAt DESC');
    return result.map((map) => CategoryModel.fromMap(map)).toList();
  }

  Future<CategoryModel?> getCategory(String id) async {
    final db = await database;
    final result = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return CategoryModel.fromMap(result.first);
  }

  Future<int> updateCategory(CategoryModel category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(String id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // Todo CRUD
  Future<String> createTodo(TodoModel todo) async {
    final db = await database;
    await db.insert('todos', todo.toMap());
    return todo.id;
  }

  Future<List<TodoModel>> getAllTodos() async {
    final db = await database;
    final result = await db.query('todos', orderBy: 'createdAt DESC');
    return result.map((map) => TodoModel.fromMap(map)).toList();
  }

  Future<List<TodoModel>> getTodosByCategory(String categoryId) async {
    final db = await database;
    final result = await db.query(
      'todos',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => TodoModel.fromMap(map)).toList();
  }

  Future<List<TodoModel>> getTodayTodos() async {
    final db = await database;
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todayEnd = todayStart.add(const Duration(days: 1));
    
    final result = await db.query(
      'todos',
      where: 'dueDate >= ? AND dueDate < ?',
      whereArgs: [
        todayStart.toIso8601String(),
        todayEnd.toIso8601String(),
      ],
      orderBy: 'priority DESC, createdAt DESC',
    );
    return result.map((map) => TodoModel.fromMap(map)).toList();
  }

  Future<TodoModel?> getTodo(String id) async {
    final db = await database;
    final result = await db.query(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return TodoModel.fromMap(result.first);
  }

  Future<int> updateTodo(TodoModel todo) async {
    final db = await database;
    return await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> deleteTodo(String id) async {
    final db = await database;
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  // Habit CRUD
  Future<String> createHabit(HabitModel habit) async {
    final db = await database;
    await db.insert('habits', habit.toMap());
    return habit.id;
  }

  Future<List<HabitModel>> getAllHabits() async {
    final db = await database;
    final result = await db.query('habits', orderBy: 'createdAt DESC');
    return result.map((map) => HabitModel.fromMap(map)).toList();
  }

  Future<List<HabitModel>> getHabitsByCategory(String categoryId) async {
    final db = await database;
    final result = await db.query(
      'habits',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'createdAt DESC',
    );
    return result.map((map) => HabitModel.fromMap(map)).toList();
  }

  Future<HabitModel?> getHabit(String id) async {
    final db = await database;
    final result = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return HabitModel.fromMap(result.first);
  }

  Future<int> updateHabit(HabitModel habit) async {
    final db = await database;
    return await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteHabit(String id) async {
    final db = await database;
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  // Statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;
    
    final totalTodos = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM todos'),
    ) ?? 0;
    
    final completedTodos = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM todos WHERE isCompleted = 1'),
    ) ?? 0;
    
    final totalHabits = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM habits'),
    ) ?? 0;
    
    final activeHabits = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM habits'),
    ) ?? 0;
    
    return {
      'totalTodos': totalTodos,
      'completedTodos': completedTodos,
      'totalHabits': totalHabits,
      'activeHabits': activeHabits,
      'completionRate': totalTodos > 0 ? (completedTodos / totalTodos) * 100 : 0.0,
    };
  }
}

