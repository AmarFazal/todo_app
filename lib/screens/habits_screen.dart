import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/habit_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/habit_item.dart';
import 'add_habit_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HabitProvider>().loadHabits();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final habitProvider = context.watch<HabitProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    final habits = habitProvider.habits;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Habits'),
      ),
      body: habits.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.repeat_rounded,
                    size: 80,
                    color: Colors.grey.shade300,
                  )
                      .animate()
                      .scale(delay: 200.ms, duration: 500.ms)
                      .then()
                      .shimmer(duration: 2000.ms),
                  const SizedBox(height: 16),
                  Text(
                    'No habits yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start building good habits today!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: habits.length,
              itemBuilder: (context, index) {
                final habit = habits[index];
                final category = categoryProvider.getCategoryById(habit.categoryId);
                return HabitItem(
                  habit: habit,
                  category: category,
                  onTap: () {
                    // Navigate to habit detail/edit
                  },
                  onToggle: () => habitProvider.toggleHabitToday(habit.id),
                )
                    .animate(delay: (index * 50).ms)
                    .fadeIn(duration: 300.ms)
                    .slideX(begin: -0.1, end: 0);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add_habit_fab',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddHabitScreen()),
          );
          if (result == true) {
            habitProvider.loadHabits();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New Habit'),
      )
          .animate()
          .scale(delay: 200.ms, duration: 300.ms)
          .then()
          .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
    );
  }
}

