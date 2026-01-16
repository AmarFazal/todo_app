import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/todo_model.dart';
import '../models/category_model.dart';
import 'animated_card.dart';

class TodoItem extends StatefulWidget {
  final TodoModel todo;
  final CategoryModel? category;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TodoItem({
    super.key,
    required this.todo,
    this.category,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> with SingleTickerProviderStateMixin {
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
    
    if (widget.todo.isCompleted) {
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
    if (!widget.todo.isCompleted) {
      _checkAnimationController.forward();
      _confettiController.play();
    } else {
      _checkAnimationController.reverse();
    }
    widget.onToggle();
  }

  Color _getPriorityColor() {
    switch (widget.todo.priority) {
      case 2:
        return Colors.red;
      case 1:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = widget.category?.color != null
        ? Color(int.parse(widget.category!.color.replaceFirst('#', '0xFF')))
        : theme.colorScheme.primary;

    return Stack(
      children: [
        AnimatedCard(
          onTap: widget.onTap,
          child: Row(
            children: [
              GestureDetector(
                onTap: _handleToggle,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.todo.isCompleted
                          ? categoryColor
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                    color: widget.todo.isCompleted
                        ? categoryColor
                        : Colors.transparent,
                  ),
                  child: widget.todo.isCompleted
                      ? ScaleTransition(
                          scale: _checkAnimation,
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
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
                      widget.todo.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: widget.todo.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: widget.todo.isCompleted
                            ? Colors.grey
                            : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    if (widget.todo.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.todo.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (widget.category != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.category!.icon,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.category!.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: categoryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (widget.category != null) const SizedBox(width: 8),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getPriorityColor(),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.todo.priority == 2
                              ? 'High'
                              : widget.todo.priority == 1
                                  ? 'Medium'
                                  : 'Low',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (widget.todo.dueDate != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDate(widget.todo.dueDate!),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: widget.onDelete,
                icon: const Icon(Icons.delete_outline),
                color: Colors.red.shade300,
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}

