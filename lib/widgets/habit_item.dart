import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/habit_model.dart';
import '../models/category_model.dart';
import 'animated_card.dart';

class HabitItem extends StatefulWidget {
  final HabitModel habit;
  final CategoryModel? category;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const HabitItem({
    super.key,
    required this.habit,
    this.category,
    required this.onTap,
    required this.onToggle,
  });

  @override
  State<HabitItem> createState() => _HabitItemState();
}

class _HabitItemState extends State<HabitItem>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _checkAnimationController;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _checkAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _checkAnimation = CurvedAnimation(
      parent: _checkAnimationController,
      curve: Curves.elasticOut,
    );
    
    if (widget.habit.isCompletedToday()) {
      _checkAnimationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _checkAnimationController.dispose();
    super.dispose();
  }

  void _handleToggle() {
    if (!widget.habit.isCompletedToday()) {
      _checkAnimationController.forward();
      _confettiController.play();
    } else {
      _checkAnimationController.reverse();
    }
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final habitColor = Color(int.parse(widget.habit.color.replaceFirst('#', '0xFF')));
    final isCompleted = widget.habit.isCompletedToday();
    final weekProgress = widget.habit.getWeekProgress();
    final progressPercent = widget.habit.targetDays > 0
        ? (weekProgress / widget.habit.targetDays).clamp(0.0, 1.0)
        : 0.0;

    return Stack(
      children: [
        AnimatedCard(
          onTap: widget.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _handleToggle,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted ? habitColor : Colors.grey.shade300,
                          width: 2.5,
                        ),
                        color: isCompleted ? habitColor : Colors.transparent,
                      ),
                      child: isCompleted
                          ? ScaleTransition(
                              scale: _checkAnimation,
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.habit.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        if (widget.habit.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.habit.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            size: 20,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.habit.streak}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${weekProgress}/${widget.habit.targetDays}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progressPercent,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(habitColor),
                        minHeight: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(progressPercent * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: habitColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final now = DateTime.now();
                  final weekStart = now.subtract(Duration(days: now.weekday - 1));
                  final date = weekStart.add(Duration(days: index));
                  final dateKey = '${date.year}-${date.month}-${date.day}';
                  final isCompleted = widget.habit.weeklyProgress[dateKey] == true;
                  final isToday = date.year == now.year &&
                      date.month == now.month &&
                      date.day == now.day;

                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? habitColor
                          : isToday
                              ? habitColor.withOpacity(0.2)
                              : Colors.grey.shade200,
                      border: isToday
                          ? Border.all(color: habitColor, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        _getDayName(index),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isCompleted
                              ? Colors.white
                              : isToday
                                  ? habitColor
                                  : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 1.57,
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.1,
          ),
        ),
      ],
    );
  }

  String _getDayName(int index) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return days[index];
  }
}

