import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/todo_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/todo_item.dart';
import 'add_todo_screen.dart';

class TodosScreen extends StatefulWidget {
  const TodosScreen({super.key});

  @override
  State<TodosScreen> createState() => _TodosScreenState();
}

class _TodosScreenState extends State<TodosScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().loadTodos();
      context.read<CategoryProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todoProvider = context.watch<TodoProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    final allTodos = todoProvider.todos;
    final pendingTodos = todoProvider.getPendingTodos();
    final completedTodos = todoProvider.getCompletedTodos();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodoList(allTodos, categoryProvider, todoProvider, theme),
          _buildTodoList(pendingTodos, categoryProvider, todoProvider, theme),
          _buildTodoList(completedTodos, categoryProvider, todoProvider, theme),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTodoScreen()),
          );
          if (result == true) {
            todoProvider.loadTodos();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('New Task'),
      )
          .animate()
          .scale(delay: 200.ms, duration: 300.ms)
          .then()
          .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
    );
  }

  Widget _buildTodoList(
    List todos,
    CategoryProvider categoryProvider,
    TodoProvider todoProvider,
    ThemeData theme,
  ) {
    if (todos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt_rounded,
              size: 80,
              color: Colors.grey.shade300,
            )
                .animate()
                .scale(delay: 200.ms, duration: 500.ms)
                .then()
                .shimmer(duration: 2000.ms),
            const SizedBox(height: 16),
            Text(
              'No tasks found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add a new task',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        final category = categoryProvider.getCategoryById(todo.categoryId);
        return TodoItem(
          todo: todo,
          category: category,
          onTap: () {
            // Navigate to todo detail/edit
          },
          onToggle: () => todoProvider.toggleTodo(todo.id),
          onDelete: () => todoProvider.deleteTodo(todo.id),
        )
            .animate(delay: (index * 50).ms)
            .fadeIn(duration: 300.ms)
            .slideX(begin: -0.1, end: 0);
      },
    );
  }
}

