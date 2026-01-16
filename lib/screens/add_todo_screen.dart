import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/todo_provider.dart';
import '../providers/category_provider.dart';
import '../models/todo_model.dart';
import '../widgets/animated_button.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({super.key});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCategoryId;
  DateTime? _dueDate;
  int _priority = 1;
  TimeOfDay? _reminderTime;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
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

  Future<void> _saveTodo() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a category')),
        );
        return;
      }

      final todo = TodoModel(
        id: const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        categoryId: _selectedCategoryId!,
        createdAt: DateTime.now(),
        dueDate: _dueDate,
        priority: _priority,
        reminderTime: _reminderTime != null
            ? '${_reminderTime!.hour}:${_reminderTime!.minute}'
            : null,
      );

      await context.read<TodoProvider>().addTodo(todo);
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = categoryProvider.categories;

    if (categories.isEmpty) {
      categoryProvider.loadCategories();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Task'),
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
                hintText: 'Enter task title',
                prefixIcon: Icon(Icons.title_rounded),
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
                hintText: 'Enter task description (optional)',
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
              leading: const Icon(Icons.calendar_today_rounded),
              title: const Text('Due Date'),
              subtitle: Text(_dueDate == null
                  ? 'Not set'
                  : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: _selectDate,
              ),
              onTap: _selectDate,
            )
                .animate(delay: 300.ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: -0.1, end: 0),
            const SizedBox(height: 8),
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
                .animate(delay: 400.ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: -0.1, end: 0),
            const SizedBox(height: 16),
            const Text(
              'Priority',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            )
                .animate(delay: 500.ms)
                .fadeIn(duration: 300.ms),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildPriorityOption(0, 'Low', Colors.blue),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPriorityOption(1, 'Medium', Colors.orange),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPriorityOption(2, 'High', Colors.red),
                ),
              ],
            )
                .animate(delay: 600.ms)
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 32),
            AnimatedButton(
              text: 'Create Task',
              icon: Icons.check_rounded,
              onPressed: _saveTodo,
              width: double.infinity,
            )
                .animate(delay: 700.ms)
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityOption(int priority, String label, Color color) {
    final isSelected = _priority == priority;
    return GestureDetector(
      onTap: () => setState(() => _priority = priority),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

