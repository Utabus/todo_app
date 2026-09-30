import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../entities/subtask.dart';
import '../entities/todo.dart';
import '../enums/todo_priority.dart';
import '../enums/todo_status.dart';

abstract interface class TodoRepository {
  Stream<List<Todo>> watchTodos({
    String? categoryId,
    TodoPriority? priority,
    TodoStatus? status,
  });

  Future<Result<List<Todo>, Failure>> getTodos();
  Future<Result<Todo, Failure>> getTodoById(String id);
  Future<Result<String, Failure>> createTodo(Todo todo);
  Future<Result<void, Failure>> updateTodo(Todo todo);
  Future<Result<void, Failure>> toggleComplete(String id, bool isCompleted);
  Future<Result<void, Failure>> deleteTodo(String id);
  Future<Result<void, Failure>> clearCompleted();

  // Subtask operations
  Future<Result<void, Failure>> addSubtask(String todoId, Subtask subtask);
  Future<Result<void, Failure>> toggleSubtask(String todoId, String subtaskId, bool isCompleted);
  Future<Result<void, Failure>> deleteSubtask(String todoId, String subtaskId);
}
