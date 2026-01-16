import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/habit_provider.dart';
import '../providers/category_provider.dart';
import '../models/habit_model.dart';
import '../widgets/animated_button.dart';
import '../utils/notification_helper.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategoryId;
  int _targetDays = 5;
  TimeOfDay? _reminderTime;
  String _selectedColor = '#6366F1';

  final List<String> _colors = [
    '#6366F1', // Indigo
    '#3B82F6', // Blue
    '#10B981', // Green
    '#F59E0B', // Amber
    '#EF4444', // Red
    '#8B5CF6', // Purple
    '#EC4899', // Pink
    '#06B6D4', // Cyan
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _reminderTime = picked);
    }
  }

  Future<void> _saveHabit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')),
        );
        return;
      }

      final habitId = const Uuid().v4();
      final habit = HabitModel(
        id: habitId,
        title: _titleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        categoryId: _selectedCategoryId!,
        createdAt: DateTime.now(),
        targetDays: _targetDays,
        reminderTime: _reminderTime != null
            ? '${_reminderTime!.hour}:${_reminderTime!.minute}'
            : null,
        color: _selectedColor,
      );

      await context.read<HabitProvider>().addHabit(habit);
      
      // Schedule daily notification if reminder time is set
      if (_reminderTime != null) {
        final now = DateTime.now();
        var notificationDate = DateTime(
          now.year,
          now.month,
          now.day,
          _reminderTime!.hour,
          _reminderTime!.minute,
        );
        
        // If the notification time has passed today, schedule for tomorrow
        if (notificationDate.isBefore(now)) {
          notificationDate = notificationDate.add(const Duration(days: 1));
        }
        
        // Use a hash of the ID as notification ID to ensure uniqueness
        final notificationId = habitId.hashCode.abs() % 2147483647;
        
        await NotificationHelper.scheduleNotification(
          id: notificationId,
          title: 'Habit Reminder: ${_titleController.text}',
          body: 'Time to work on your habit! Keep your streak going! 🔥',
          scheduledDate: notificationDate,
        );
      }
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = categoryProvider.categories;

    if (categories.isEmpty) {
      categoryProvider.loadCategories();
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New Habit'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter habit title',
                prefixIcon: Icon(Icons.repeat_rounded),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideX(begin: -0.1, end: 0),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Enter habit description (optional)',
                prefixIcon: Icon(Icons.description_rounded),
              ),
              maxLines: 3,
            )
                .animate(delay: 100.ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: -0.1, end: 0),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Category *',
                prefixIcon: Icon(Icons.category_rounded),
              ),
              value: _selectedCategoryId,
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category.id,
                  child: Row(
                    children: [
                      Text(category.icon),
                      const SizedBox(width: 8),
                      Text(category.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategoryId = value),
              validator: (value) {
                if (value == null) {
                  return 'Please select a category';
                }
                return null;
              },
            )
                .animate(delay: 200.ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: -0.1, end: 0),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.notifications_rounded),
              title: const Text('Reminder Time'),
              subtitle: Text(_reminderTime == null
                  ? 'Not set'
                  : _reminderTime!.format(context)),
              trailing: IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: _selectTime,
              ),
              onTap: _selectTime,
            )
                .animate(delay: 300.ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: -0.1, end: 0),
            const SizedBox(height: 16),
            const Text(
              'Weekly Target',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            )
                .animate(delay: 400.ms)
                .fadeIn(duration: 300.ms),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _targetDays.toDouble(),
                    min: 1,
                    max: 7,
                    divisions: 6,
                    label: '$_targetDays days',
                    onChanged: (value) {
                      setState(() => _targetDays = value.toInt());
                    },
                  ),
                ),
                Container(
                  width: 50,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_targetDays',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            )
                .animate(delay: 500.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 16),
            const Text(
              'Color',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            )
                .animate(delay: 600.ms)
                .fadeIn(duration: 300.ms),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colors.map((color) {
                final isSelected = _selectedColor == color;
                final colorValue = Color(int.parse(color.replaceFirst('#', '0xFF')));
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: colorValue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: colorValue.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 24)
                        : null,
                  ),
                );
              }).toList(),
            )
                .animate(delay: 700.ms)
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
            const SizedBox(height: 32),
            AnimatedButton(
              text: 'Create Habit',
              icon: Icons.check_rounded,
              onPressed: _saveHabit,
              width: double.infinity,
            )
                .animate(delay: 800.ms)
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
          ],
        ),
      ),
    );
  }
}

