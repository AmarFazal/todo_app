import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/todo_provider.dart';
import '../providers/habit_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/animated_card.dart';
import '../widgets/todo_item.dart';
import '../widgets/habit_item.dart';
import 'todos_screen.dart';
import 'habits_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().loadTodos();
      context.read<HabitProvider>().loadHabits();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todoProvider = context.watch<TodoProvider>();
    final habitProvider = context.watch<HabitProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    final todayTodos = todoProvider.getTodayTodos();
    final pendingTodos = todoProvider.getPendingTodos();
    final activeHabits = habitProvider.habits;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeContent(
            context,
            theme,
            todayTodos,
            pendingTodos,
            activeHabits,
            categoryProvider,
            todoProvider,
            habitProvider,
          ),
          const TodosScreen(),
          const HabitsScreen(),
          const StatsScreen(),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_rounded, 'Home', 0),
                _buildNavItem(Icons.checklist_rounded, 'Todos', 1),
                _buildNavItem(Icons.repeat_rounded, 'Habits', 2),
                _buildNavItem(Icons.insights_rounded, 'Stats', 3),
                _buildNavItem(Icons.settings_rounded, 'Settings', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      )
          .animate(target: isSelected ? 1 : 0)
          .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1))
          .then()
          .scale(begin: const Offset(1.1, 1.1), end: const Offset(1, 1)),
    );
  }

  Widget _buildHomeContent(
    BuildContext context,
    ThemeData theme,
    List todayTodos,
    List pendingTodos,
    List activeHabits,
    CategoryProvider categoryProvider,
    TodoProvider todoProvider,
    HabitProvider habitProvider,
  ) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Welcome Back!',
              style: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
            titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatsCards(theme, todoProvider, habitProvider)
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: 24),
                if (todayTodos.isNotEmpty) ...[
                  _buildSectionHeader('Today\'s Tasks', Icons.today_rounded, theme)
                      .animate()
                      .fadeIn(duration: 300.ms),
                  const SizedBox(height: 12),
                  ...todayTodos.take(3).map((todo) {
                    final category = categoryProvider.getCategoryById(todo.categoryId);
                    return TodoItem(
                      todo: todo,
                      category: category,
                      onTap: () {
                        // Navigate to todo detail
                      },
                      onToggle: () => todoProvider.toggleTodo(todo.id),
                      onDelete: () => todoProvider.deleteTodo(todo.id),
                    );
                  }).toList(),
                  if (todayTodos.length > 3)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: TextButton(
                          onPressed: () => setState(() => _currentIndex = 1),
                          child: const Text('View All Tasks'),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
                if (activeHabits.isNotEmpty) ...[
                  _buildSectionHeader('Active Habits', Icons.repeat_rounded, theme)
                      .animate()
                      .fadeIn(duration: 300.ms),
                  const SizedBox(height: 12),
                  ...activeHabits.take(3).map((habit) {
                    final category = categoryProvider.getCategoryById(habit.categoryId);
                    return HabitItem(
                      habit: habit,
                      category: category,
                      onTap: () {
                        // Navigate to habit detail
                      },
                      onToggle: () => habitProvider.toggleHabitToday(habit.id),
                    );
                  }).toList(),
                  if (activeHabits.length > 3)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: TextButton(
                          onPressed: () => setState(() => _currentIndex = 2),
                          child: const Text('View All Habits'),
                        ),
                      ),
                    ),
                ],
                if (todayTodos.isEmpty && activeHabits.isEmpty)
                  _buildEmptyState(theme)
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scale(begin: const Offset(0.9, 0.9)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(ThemeData theme, TodoProvider todoProvider, HabitProvider habitProvider) {
    final completedTodos = todoProvider.getCompletedTodos().length;
    final totalTodos = todoProvider.todos.length;
    final totalStreak = habitProvider.habits.fold<int>(
      0,
      (sum, habit) => sum + habit.streak,
    );

    return Row(
      children: [
        Expanded(
          child: AnimatedCard(
            color: theme.colorScheme.primary.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const Spacer(),
                    Text(
                      '$completedTodos/$totalTodos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Tasks Done',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AnimatedCard(
            color: Colors.orange.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.orange,
                      size: 24,
                    ),
                    const Spacer(),
                    Text(
                      '$totalStreak',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Streak',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.task_alt_rounded,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks or habits yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start by adding your first task or habit!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

