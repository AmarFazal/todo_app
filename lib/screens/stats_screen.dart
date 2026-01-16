import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/todo_provider.dart';
import '../providers/habit_provider.dart';
import '../widgets/animated_card.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todoProvider = context.watch<TodoProvider>();
    final habitProvider = context.watch<HabitProvider>();

    final totalTodos = todoProvider.todos.length;
    final completedTodos = todoProvider.getCompletedTodos().length;
    final pendingTodos = todoProvider.getPendingTodos().length;
    final totalHabits = habitProvider.habits.length;
    final totalStreak = habitProvider.habits.fold<int>(
      0,
      (sum, habit) => sum + habit.streak,
    );
    final longestStreak = habitProvider.habits.isEmpty
        ? 0
        : habitProvider.habits
            .map((h) => h.longestStreak)
            .reduce((a, b) => a > b ? a : b);
    final completionRate = totalTodos > 0
        ? (completedTodos / totalTodos * 100).round()
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCard(
              theme,
              'Completion Rate',
              '$completionRate%',
              Icons.trending_up_rounded,
              theme.colorScheme.primary,
              completionRate.toDouble(),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Total Tasks',
                    '$totalTodos',
                    Icons.checklist_rounded,
                    Colors.blue,
                    null,
                  )
                      .animate(delay: 100.ms)
                      .fadeIn(duration: 300.ms)
                      .slideX(begin: -0.1, end: 0),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Completed',
                    '$completedTodos',
                    Icons.check_circle_rounded,
                    Colors.green,
                    null,
                  )
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 300.ms)
                      .slideX(begin: 0.1, end: 0),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Pending',
                    '$pendingTodos',
                    Icons.pending_rounded,
                    Colors.orange,
                    null,
                  )
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 300.ms)
                      .slideX(begin: -0.1, end: 0),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Active Habits',
                    '$totalHabits',
                    Icons.repeat_rounded,
                    Colors.purple,
                    null,
                  )
                      .animate(delay: 400.ms)
                      .fadeIn(duration: 300.ms)
                      .slideX(begin: 0.1, end: 0),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Habit Streaks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            )
                .animate(delay: 500.ms)
                .fadeIn(duration: 300.ms),
            const SizedBox(height: 12),
            _buildStatCard(
              theme,
              'Total Streak',
              '$totalStreak days',
              Icons.local_fire_department,
              Colors.orange,
              null,
            )
                .animate(delay: 600.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 16),
            _buildStatCard(
              theme,
              'Longest Streak',
              '$longestStreak days',
              Icons.emoji_events_rounded,
              Colors.amber,
              null,
            )
                .animate(delay: 700.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
    double? progress,
  ) {
    return AnimatedCard(
      color: color.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const Spacer(),
              if (progress != null)
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
            ],
          ),
          if (progress == null) ...[
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

