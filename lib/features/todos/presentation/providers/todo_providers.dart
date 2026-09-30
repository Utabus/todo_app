import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/todo_repository_impl.dart';
import '../../domain/entities/subtask.dart';
import '../../domain/entities/todo.dart';
import '../../domain/enums/todo_priority.dart';
import '../../domain/enums/todo_status.dart';
import '../../domain/repositories/todo_repository.dart';

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepositoryImpl();
});

class TodoFilterState {
  final String searchQuery;
  final TodoPriority? selectedPriority;
  final String? selectedCategory;
  final TodoStatus? selectedStatus;

  const TodoFilterState({
    this.searchQuery = '',
    this.selectedPriority,
    this.selectedCategory,
    this.selectedStatus,
  });

  TodoFilterState copyWith({
    String? searchQuery,
    TodoPriority? selectedPriority,
    String? selectedCategory,
    TodoStatus? selectedStatus,
    bool clearPriority = false,
    bool clearCategory = false,
    bool clearStatus = false,
  }) {
    return TodoFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedPriority: clearPriority ? null : (selectedPriority ?? this.selectedPriority),
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
    );
  }
}

class TodoFilterNotifier extends Notifier<TodoFilterState> {
  @override
  TodoFilterState build() => const TodoFilterState();

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setPriority(TodoPriority? priority) {
    if (priority == null) {
      state = state.copyWith(clearPriority: true);
    } else {
      state = state.copyWith(selectedPriority: priority);
    }
  }

  void setCategory(String? category) {
    if (category == null) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  void setStatus(TodoStatus? status) {
    if (status == null) {
      state = state.copyWith(clearStatus: true);
    } else {
      state = state.copyWith(selectedStatus: status);
    }
  }

  void reset() {
    state = const TodoFilterState();
  }
}

final todoFilterProvider = NotifierProvider<TodoFilterNotifier, TodoFilterState>(() {
  return TodoFilterNotifier();
});

/// Raw realtime stream from repository
final todoStreamProvider = StreamProvider<List<Todo>>((ref) {
  final repo = ref.watch(todoRepositoryProvider);
  return repo.watchTodos();
});

/// Filtered todos provider combining stream with filter parameters
final filteredTodosProvider = Provider<AsyncValue<List<Todo>>>((ref) {
  final todosAsync = ref.watch(todoStreamProvider);
  final filter = ref.watch(todoFilterProvider);

  return todosAsync.whenData((todos) {
    return todos.where((todo) {
      if (filter.searchQuery.isNotEmpty) {
        final q = filter.searchQuery.toLowerCase();
        final matchTitle = todo.title.toLowerCase().contains(q);
        final matchDesc = todo.description?.toLowerCase().contains(q) ?? false;
        final matchTags = todo.tags.any((t) => t.toLowerCase().contains(q));
        if (!matchTitle && !matchDesc && !matchTags) return false;
      }
      if (filter.selectedPriority != null && todo.priority != filter.selectedPriority) {
        return false;
      }
      if (filter.selectedCategory != null &&
          todo.categoryId != filter.selectedCategory &&
          todo.categoryName != filter.selectedCategory) {
        return false;
      }
      if (filter.selectedStatus != null && todo.status != filter.selectedStatus) {
        return false;
      }
      return true;
    }).toList();
  });
});

final todayTodosProvider = Provider<AsyncValue<List<Todo>>>((ref) {
  final todosAsync = ref.watch(todoStreamProvider);
  return todosAsync.whenData((todos) {
    return todos.where((t) => !t.isOverdue && !t.isCompleted).toList();
  });
});

final overdueTodosProvider = Provider<AsyncValue<List<Todo>>>((ref) {
  final todosAsync = ref.watch(todoStreamProvider);
  return todosAsync.whenData((todos) {
    return todos.where((t) => t.isOverdue && !t.isCompleted).toList();
  });
});

final completedTodosProvider = Provider<AsyncValue<List<Todo>>>((ref) {
  final todosAsync = ref.watch(todoStreamProvider);
  return todosAsync.whenData((todos) {
    return todos.where((t) => t.isCompleted).toList();
  });
});

/// Todo detail provider family
final todoDetailProvider = StreamProvider.family<Todo?, String>((ref, id) {
  final repo = ref.watch(todoRepositoryProvider);
  return repo.watchTodos().map((todos) {
    final matches = todos.where((t) => t.id == id);
    return matches.isNotEmpty ? matches.first : null;
  });
});

/// Action controller for mutations
class TodoController {
  final TodoRepository _repository;
  TodoController(this._repository);

  Future<void> toggleComplete(String id, bool isCompleted) async {
    await _repository.toggleComplete(id, isCompleted);
  }

  Future<void> createTodo(Todo todo) async {
    await _repository.createTodo(todo);
  }

  Future<void> updateTodo(Todo todo) async {
    await _repository.updateTodo(todo);
  }

  Future<void> deleteTodo(String id) async {
    await _repository.deleteTodo(id);
  }

  Future<void> clearCompleted() async {
    await _repository.clearCompleted();
  }

  Future<void> addSubtask(String todoId, Subtask subtask) async {
    await _repository.addSubtask(todoId, subtask);
  }

  Future<void> toggleSubtask(String todoId, String subtaskId, bool isCompleted) async {
    await _repository.toggleSubtask(todoId, subtaskId, isCompleted);
  }

  Future<void> deleteSubtask(String todoId, String subtaskId) async {
    await _repository.deleteSubtask(todoId, subtaskId);
  }
}

final todoControllerProvider = Provider<TodoController>((ref) {
  final repo = ref.watch(todoRepositoryProvider);
  return TodoController(repo);
});
