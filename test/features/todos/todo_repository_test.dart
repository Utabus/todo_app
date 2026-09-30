import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/features/todos/data/repositories/todo_repository_impl.dart';
import 'package:todo_app/features/todos/domain/entities/subtask.dart';
import 'package:todo_app/features/todos/domain/entities/todo.dart';
import 'package:todo_app/features/todos/domain/enums/todo_priority.dart';
import 'package:todo_app/features/todos/domain/enums/todo_status.dart';

void main() {
  group('TodoRepositoryImpl Tests', () {
    late TodoRepositoryImpl repository;

    setUp(() {
      repository = TodoRepositoryImpl(initialTodos: []);
    });

    test('Initial repository should be empty when initialized with empty list', () async {
      final result = await repository.getTodos();
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isEmpty);
    });

    test('createTodo should add todo and be retrievable', () async {
      const todo = Todo(
        id: 'test_1',
        title: 'Complete production spec',
        status: TodoStatus.active,
        priority: TodoPriority.high,
      );

      final createResult = await repository.createTodo(todo);
      expect(createResult.isSuccess, isTrue);
      expect(createResult.dataOrNull, equals('test_1'));

      final getResult = await repository.getTodoById('test_1');
      expect(getResult.isSuccess, isTrue);
      expect(getResult.dataOrNull?.title, equals('Complete production spec'));
      expect(getResult.dataOrNull?.priority, equals(TodoPriority.high));
    });

    test('toggleComplete should update todo status to completed and set completedAt', () async {
      const todo = Todo(
        id: 'test_toggle',
        title: 'Check toggle behavior',
        status: TodoStatus.active,
      );
      await repository.createTodo(todo);

      final toggleResult = await repository.toggleComplete('test_toggle', true);
      expect(toggleResult.isSuccess, isTrue);

      final fetched = await repository.getTodoById('test_toggle');
      expect(fetched.dataOrNull?.isCompleted, isTrue);
      expect(fetched.dataOrNull?.status, equals(TodoStatus.completed));
      expect(fetched.dataOrNull?.completedAt, isNotNull);
    });

    test('addSubtask and toggleSubtask should accurately update subtask counts', () async {
      const todo = Todo(
        id: 'test_subtasks',
        title: 'Task with subtasks',
        status: TodoStatus.active,
      );
      await repository.createTodo(todo);

      final subtask1 = Subtask(
        id: 'sub_1',
        title: 'Subtask 1',
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      await repository.addSubtask('test_subtasks', subtask1);

      var fetched = await repository.getTodoById('test_subtasks');
      expect(fetched.dataOrNull?.subtaskCount, equals(1));
      expect(fetched.dataOrNull?.completedSubtaskCount, equals(0));

      await repository.toggleSubtask('test_subtasks', 'sub_1', true);

      fetched = await repository.getTodoById('test_subtasks');
      expect(fetched.dataOrNull?.subtaskCount, equals(1));
      expect(fetched.dataOrNull?.completedSubtaskCount, equals(1));
    });

    test('deleteTodo should remove the todo from repository', () async {
      const todo = Todo(
        id: 'test_delete',
        title: 'Task to be deleted',
      );
      await repository.createTodo(todo);

      final deleteResult = await repository.deleteTodo('test_delete');
      expect(deleteResult.isSuccess, isTrue);

      final getResult = await repository.getTodoById('test_delete');
      expect(getResult.isError, isTrue);
    });
  });
}
