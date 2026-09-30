import 'dart:async';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/subtask.dart';
import '../../domain/entities/todo.dart';
import '../../domain/enums/todo_priority.dart';
import '../../domain/enums/todo_status.dart';
import '../../domain/repositories/todo_repository.dart';

/// TodoRepositoryImpl: manages data source streams and CRUD operations
class TodoRepositoryImpl implements TodoRepository {
  final List<Todo> _todos = [];
  final _controller = StreamController<List<Todo>>.broadcast();

  TodoRepositoryImpl({List<Todo>? initialTodos}) {
    if (initialTodos != null) {
      _todos.addAll(initialTodos);
    } else {
      _todos.addAll(_defaultMockTodos());
    }
    _emit();
  }

  void _emit() {
    _controller.add(List.unmodifiable(_todos));
  }

  static List<Todo> _defaultMockTodos() {
    return [
      Todo(
        id: 't0',
        title: 'Review Firebase security rules',
        description: 'Verify Firestore rules for tenant isolation and rate-limiting endpoints before launching test flight.',
        status: TodoStatus.active,
        priority: TodoPriority.high,
        dueAt: DateTime.now().subtract(const Duration(days: 1)),
        categoryName: 'Development',
        tags: const ['firebase', 'security'],
        subtaskCount: 2,
        completedSubtaskCount: 1,
        subtasks: [
          Subtask(id: 's01', title: 'Audit Firestore read rules', isCompleted: true, createdAt: DateTime.now()),
          Subtask(id: 's02', title: 'Enforce user UID validation', isCompleted: false, createdAt: DateTime.now()),
        ],
      ),
      Todo(
        id: 't1',
        title: 'Finish Flutter architecture & design tokens',
        description: 'Implement Calm Productivity theme tokens, spacing, typography, and test with dynamic type scaling.',
        status: TodoStatus.active,
        priority: TodoPriority.high,
        dueAt: DateTime.now().add(const Duration(hours: 4)),
        categoryName: 'Work',
        tags: const ['flutter', 'architecture'],
        subtaskCount: 5,
        completedSubtaskCount: 2,
        subtasks: [
          Subtask(id: 's1', title: 'Extract AppColors & AppTypography', isCompleted: true, createdAt: DateTime.now()),
          Subtask(id: 's2', title: 'Setup M3 ThemeData', isCompleted: true, createdAt: DateTime.now()),
          Subtask(id: 's3', title: 'Build TaskRowItem primitive with 48dp hit-targets', isCompleted: false, createdAt: DateTime.now()),
          Subtask(id: 's4', title: 'Implement Today Screen layout', isCompleted: false, createdAt: DateTime.now()),
          Subtask(id: 's5', title: 'Verify WCAG AAA contrast compliance', isCompleted: false, createdAt: DateTime.now()),
        ],
      ),
      Todo(
        id: 't2',
        title: 'Team standup and sprint planning',
        description: 'Align on Q4 Sprint goals and discuss task prioritization with the core team.',
        status: TodoStatus.active,
        priority: TodoPriority.medium,
        dueAt: DateTime.now().add(const Duration(hours: 2)),
        categoryName: 'Work',
        tags: const ['meeting', 'sprint'],
        subtaskCount: 1,
        completedSubtaskCount: 1,
        subtasks: [
          Subtask(id: 's21', title: 'Prepare slide deck for backlog grooming', isCompleted: true, createdAt: DateTime.now()),
        ],
      ),
      Todo(
        id: 't3',
        title: 'Buy groceries & weekly supplies',
        description: 'Pick up coffee beans, oats, almond milk, and fresh fruit for the pantry.',
        status: TodoStatus.active,
        priority: TodoPriority.none,
        dueAt: DateTime.now().add(const Duration(hours: 6)),
        categoryName: 'Personal',
        tags: const ['home', 'routine'],
      ),
      Todo(
        id: 't4',
        title: 'Read Flutter Riverpod state guide',
        description: 'Deep dive into AsyncNotifier, AutoDispose, and Family modifier patterns.',
        status: TodoStatus.active,
        priority: TodoPriority.low,
        dueAt: DateTime.now().add(const Duration(hours: 8)),
        categoryName: 'Learning',
        tags: const ['riverpod', 'dart'],
      ),
      Todo(
        id: 't5',
        title: 'Setup Flutter project & dependencies',
        description: 'Initialized Flutter 3 project and configured packages.',
        status: TodoStatus.completed,
        priority: TodoPriority.medium,
        completedAt: DateTime.now().subtract(const Duration(hours: 3)),
        categoryName: 'Development',
        tags: const ['setup'],
      ),
    ];
  }

  @override
  Stream<List<Todo>> watchTodos({
    String? categoryId,
    TodoPriority? priority,
    TodoStatus? status,
  }) {
    return _controller.stream.map((list) {
      return list.where((todo) {
        if (categoryId != null && todo.categoryId != categoryId && todo.categoryName != categoryId) {
          return false;
        }
        if (priority != null && todo.priority != priority) {
          return false;
        }
        if (status != null && todo.status != status) {
          return false;
        }
        return true;
      }).toList();
    });
  }

  @override
  Future<Result<List<Todo>, Failure>> getTodos() async {
    return Success(List.unmodifiable(_todos));
  }

  @override
  Future<Result<Todo, Failure>> getTodoById(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) {
      return const Error(NotFoundFailure('Task not found'));
    }
    return Success(_todos[index]);
  }

  @override
  Future<Result<String, Failure>> createTodo(Todo todo) async {
    if (todo.title.trim().isEmpty) {
      return const Error(ValidationFailure('Task title cannot be empty'));
    }
    _todos.insert(0, todo);
    _emit();
    return Success(todo.id);
  }

  @override
  Future<Result<void, Failure>> updateTodo(Todo todo) async {
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index == -1) {
      return const Error(NotFoundFailure('Task not found to update'));
    }
    _todos[index] = todo;
    _emit();
    return const Success(null);
  }

  @override
  Future<Result<void, Failure>> toggleComplete(String id, bool isCompleted) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) {
      return const Error(NotFoundFailure('Task not found'));
    }
    final existing = _todos[index];
    _todos[index] = existing.copyWith(
      status: isCompleted ? TodoStatus.completed : TodoStatus.active,
      completedAt: isCompleted ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );
    _emit();
    return const Success(null);
  }

  @override
  Future<Result<void, Failure>> deleteTodo(String id) async {
    final before = _todos.length;
    _todos.removeWhere((t) => t.id == id);
    if (_todos.length == before) {
      return const Error(NotFoundFailure('Task not found to delete'));
    }
    _emit();
    return const Success(null);
  }

  @override
  Future<Result<void, Failure>> clearCompleted() async {
    _todos.removeWhere((t) => t.status == TodoStatus.completed);
    _emit();
    return const Success(null);
  }

  @override
  Future<Result<void, Failure>> addSubtask(String todoId, Subtask subtask) async {
    final index = _todos.indexWhere((t) => t.id == todoId);
    if (index == -1) {
      return const Error(NotFoundFailure('Task not found'));
    }
    final existing = _todos[index];
    final updatedSubtasks = [...existing.subtasks, subtask];
    _todos[index] = existing.copyWith(
      subtasks: updatedSubtasks,
      subtaskCount: updatedSubtasks.length,
      completedSubtaskCount: updatedSubtasks.where((s) => s.isCompleted).length,
      updatedAt: DateTime.now(),
    );
    _emit();
    return const Success(null);
  }

  @override
  Future<Result<void, Failure>> toggleSubtask(String todoId, String subtaskId, bool isCompleted) async {
    final index = _todos.indexWhere((t) => t.id == todoId);
    if (index == -1) {
      return const Error(NotFoundFailure('Task not found'));
    }
    final existing = _todos[index];
    final updatedSubtasks = existing.subtasks.map((s) {
      if (s.id == subtaskId) {
        return s.copyWith(isCompleted: isCompleted, updatedAt: DateTime.now());
      }
      return s;
    }).toList();

    _todos[index] = existing.copyWith(
      subtasks: updatedSubtasks,
      subtaskCount: updatedSubtasks.length,
      completedSubtaskCount: updatedSubtasks.where((s) => s.isCompleted).length,
      updatedAt: DateTime.now(),
    );
    _emit();
    return const Success(null);
  }

  @override
  Future<Result<void, Failure>> deleteSubtask(String todoId, String subtaskId) async {
    final index = _todos.indexWhere((t) => t.id == todoId);
    if (index == -1) {
      return const Error(NotFoundFailure('Task not found'));
    }
    final existing = _todos[index];
    final updatedSubtasks = existing.subtasks.where((s) => s.id != subtaskId).toList();

    _todos[index] = existing.copyWith(
      subtasks: updatedSubtasks,
      subtaskCount: updatedSubtasks.length,
      completedSubtaskCount: updatedSubtasks.where((s) => s.isCompleted).length,
      updatedAt: DateTime.now(),
    );
    _emit();
    return const Success(null);
  }
}
