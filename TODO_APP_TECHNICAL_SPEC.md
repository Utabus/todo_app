# Todo App — Technical Specification

> Version: 1.0  
> Date: 2026-09-30  
> Platform baseline: Android + iOS, architecture prepared for Web  
> Backend: Firebase  
> Database: Cloud Firestore  
> State management: Riverpod 3  
> Navigation: go_router  
> Architecture: Feature-first + MVVM + Repository/Service

---

## 1. Mục tiêu tài liệu

Tài liệu này là blueprint kỹ thuật cho Todo App Flutter có thể triển khai thành sản phẩm thật, đồng thời đủ rõ để đưa cho AI coding agent thực hiện theo từng phase.

Tài liệu tập trung vào:

- Kiến trúc ứng dụng.
- Quy ước code.
- Tổ chức source code.
- Firebase/Firestore data model.
- Authentication.
- Todo CRUD và realtime sync.
- State management.
- Routing.
- Offline-first.
- Notification/reminder.
- Security Rules.
- Error handling.
- Logging/analytics/crash reporting.
- Testing.
- Performance.
- CI/CD và release.
- Roadmap implementation theo phase.

UI/UX chưa nằm trong phạm vi của tài liệu này. UI/UX sẽ được thiết kế thành tài liệu riêng sau khi technical architecture được khóa.

---

# 2. Product baseline

## 2.1 Phạm vi MVP kỹ thuật

MVP nên có các capability sau:

1. Authentication.
2. User profile cơ bản.
3. Todo CRUD.
4. Complete/uncomplete.
5. Priority.
6. Due date/time.
7. Category.
8. Tag.
9. Subtask.
10. Search.
11. Filter.
12. Sort.
13. Reminder local.
14. Dark/light/system theme.
15. Offline read/write.
16. Realtime sync.
17. Security Rules.
18. Crash reporting.
19. Analytics cơ bản.

## 2.2 Future-ready capability

Thiết kế data model không đóng cửa cho:

- Recurring task.
- Calendar view.
- Attachment.
- Shared project.
- Workspace/team.
- AI task assistant.
- Premium subscription.
- Cross-device notification.
- Web application.
- Admin dashboard.

Không triển khai những phần này trong MVP nếu chưa có requirement rõ ràng.

---

# 3. Technology decisions

## 3.1 Core stack

| Thành phần | Quyết định | Mục đích |
|---|---|---|
| Flutter | Stable channel | UI đa nền tảng |
| Dart | Version đi cùng Flutter stable | Ngôn ngữ |
| Riverpod 3 | `flutter_riverpod` | State management + dependency injection |
| go_router | Latest stable compatible | Routing/deep link |
| Firebase Core | Latest compatible | Firebase bootstrap |
| Firebase Auth | Latest compatible | Authentication |
| Cloud Firestore | Latest compatible | Database + realtime + offline |
| Firebase Analytics | Latest compatible | Product analytics |
| Firebase Crashlytics | Latest compatible | Crash reporting |
| Firebase App Check | Latest compatible | Abuse protection |
| Firebase Messaging | Optional phase later | Push notification |
| flutter_local_notifications | Latest compatible stable | Local reminder scheduling |
| timezone | Latest compatible | Timezone-aware local scheduling |
| Freezed | Latest compatible | Immutable models + unions |
| json_serializable | Latest compatible | Serialization |
| build_runner | Latest compatible | Code generation |
| intl | Latest compatible | Date/time/format |

Tại thời điểm viết tài liệu, Riverpod 3.4.3, go_router 18.0.2 và Freezed 4.0.2 là các bản stable được phát hành trên pub.dev. go_router 18 yêu cầu tối thiểu Flutter 3.44/Dart 3.12; vì vậy project phải dùng Flutter/Dart tương thích trước khi khóa package versions. Đây là snapshot tại ngày tài liệu được tạo, không phải các version vĩnh viễn. 

## 3.2 Nguyên tắc dependency

Không thêm package chỉ vì nó phổ biến.

Mỗi package phải trả lời được một trong ba câu hỏi:

- Nó giảm đáng kể complexity?
- Nó chuẩn hóa một concern khó tự làm?
- Nó giúp test/maintainability tốt hơn?

Tránh package chồng chéo chức năng.

Ví dụ không dùng cùng lúc nhiều state-management framework.

---

# 4. Architecture

Flutter architecture guide khuyến nghị phân tách View, ViewModel, Repository và Service; domain/use-case layer chỉ nên thêm khi business logic phức tạp thực sự cần. Todo App này áp dụng mô hình đó, nhưng tổ chức theo feature để source code dễ scale. 

## 4.1 Architecture layers

```text
┌──────────────────────────────────────────────┐
│                  Presentation                │
│                                              │
│  Pages / Widgets / ViewModels / UI State     │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│                  Application                 │
│                                              │
│  Router / Session / App lifecycle /         │
│  cross-feature orchestration                 │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│                    Domain                    │
│                                              │
│  Entities / Value objects / Business rules   │
│  Use cases only when justified               │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│                     Data                     │
│                                              │
│  Repositories / DTOs / Firebase services     │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│                 Infrastructure               │
│                                              │
│ Firebase Auth / Firestore / FCM / Crashlytics│
└──────────────────────────────────────────────┘
```

## 4.2 Dependency direction

```text
UI
 ↓
ViewModel
 ↓
Repository interface
 ↓
Repository implementation
 ↓
Service
 ↓
Firebase SDK
```

Quy tắc quan trọng:

- Widget không gọi `FirebaseFirestore.instance`.
- ViewModel không chứa Firestore collection path.
- Domain entity không import Firebase.
- Firebase DTO/model mapping nằm ở data layer.
- Repository là source of truth cho data của feature.
- Service là adapter tới external dependency.

## 4.3 Khi nào cần UseCase

Không tạo `CreateTodoUseCase`, `UpdateTodoUseCase`, `DeleteTodoUseCase` chỉ để bọc một lệnh repository.

Ban đầu:

```text
View
 ↓
TodoViewModel
 ↓
TodoRepository
```

Chỉ thêm domain/use-case nếu logic trở thành orchestration có nhiều bước, ví dụ:

```text
CompleteTodo
 ├── update todo
 ├── cancel reminder
 ├── update statistics
 └── track analytics
```

Lúc đó:

```text
ViewModel
 ↓
CompleteTodoUseCase
 ├── TodoRepository
 ├── ReminderService
 └── AnalyticsService
```

---

# 5. Source code structure

Định hướng chính: **feature-first**.

```text
lib/
├── app/
│   ├── app.dart
│   ├── app_bootstrap.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   ├── route_names.dart
│   │   └── router_refresh_notifier.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   └── app_spacing.dart
│   └── config/
│       ├── app_config.dart
│       └── environment.dart
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── firestore_constants.dart
│   ├── errors/
│   │   ├── app_exception.dart
│   │   ├── failure.dart
│   │   └── error_mapper.dart
│   ├── extensions/
│   │   ├── datetime_extensions.dart
│   │   ├── string_extensions.dart
│   │   └── iterable_extensions.dart
│   ├── logging/
│   │   ├── app_logger.dart
│   │   └── firebase_logger.dart
│   ├── network/
│   │   └── connectivity_service.dart
│   ├── result/
│   │   └── result.dart
│   ├── services/
│   │   ├── analytics_service.dart
│   │   ├── notification_service.dart
│   │   └── device_service.dart
│   ├── utils/
│   │   ├── date_utils.dart
│   │   ├── debounce.dart
│   │   └── validators.dart
│   └── widgets/
│       ├── async_value_view.dart
│       ├── app_error_view.dart
│       ├── app_loading_view.dart
│       └── empty_state.dart
│
├── firebase/
│   ├── firebase_providers.dart
│   ├── auth/
│   │   └── firebase_auth_service.dart
│   ├── firestore/
│   │   ├── firestore_service.dart
│   │   └── firestore_paths.dart
│   ├── messaging/
│   │   └── firebase_messaging_service.dart
│   └── crashlytics/
│       └── crashlytics_service.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── dto/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── pages/
│   │       ├── providers/
│   │       ├── view_models/
│   │       └── widgets/
│   │
│   ├── todos/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── firestore_todo_datasource.dart
│   │   │   ├── dto/
│   │   │   │   ├── todo_dto.dart
│   │   │   │   └── subtask_dto.dart
│   │   │   └── repositories/
│   │   │       └── todo_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   ├── todo.dart
│   │   │   │   └── subtask.dart
│   │   │   ├── enums/
│   │   │   │   ├── todo_priority.dart
│   │   │   │   └── todo_status.dart
│   │   │   └── repositories/
│   │   │       └── todo_repository.dart
│   │   └── presentation/
│   │       ├── pages/
│   │       │   ├── todo_list_page.dart
│   │       │   ├── todo_detail_page.dart
│   │       │   └── todo_editor_page.dart
│   │       ├── providers/
│   │       ├── view_models/
│   │       └── widgets/
│   │
│   ├── categories/
│   ├── search/
│   ├── settings/
│   ├── profile/
│   └── notifications/
│
├── l10n/
│   └── app_*.arb
│
├── main.dart
└── firebase_options.dart
```

## 5.1 Quy tắc thư mục

### `app/`

Chỉ chứa concern toàn ứng dụng: bootstrap, router, theme, environment.

### `core/`

Chứa reusable infrastructure không phụ thuộc business feature.

Không biến `core` thành “thùng rác”. Nếu code chỉ dùng cho Todo thì để trong `features/todos`.

### `firebase/`

Chứa adapter/integration với Firebase SDK dùng chung.

### `features/`

Mỗi feature phải gần như độc lập.

---

# 6. Naming conventions

## 6.1 File

Dùng `snake_case`:

```text
todo_repository.dart
todo_repository_impl.dart
todo_list_page.dart
```

## 6.2 Class

```text
TodoRepository
TodoRepositoryImpl
TodoViewModel
TodoDto
FirestoreTodoDataSource
```

## 6.3 Private members

```dart
final class TodoRepositoryImpl implements TodoRepository {
  final FirestoreTodoDataSource _dataSource;
}
```

## 6.4 Provider

Tên provider mô tả dependency hoặc state:

```dart
authStateProvider
todoListProvider
todoDetailProvider
todoFilterProvider
```

---

# 7. State management

Riverpod được dùng cho:

- Dependency injection.
- Async state.
- Feature state.
- Realtime listeners.
- Derived state.
- Session state.

Riverpod hiện cung cấp khả năng xử lý loading/error, pull-to-refresh và tách logic khỏi UI, phù hợp với architecture này. 

## 7.1 Không lưu state ở Widget khi state thuộc business

Không làm:

```dart
class TodoPage extends StatefulWidget {
  bool isLoading = false;
}
```

Nên làm:

```text
TodoPage
  ↓
ref.watch(todoListProvider)
```

## 7.2 State categories

### Local UI state

Có thể để trong Widget:

- Text editing state.
- Tab index.
- Animation state.
- Temporary dialog state.

### Feature state

Để Riverpod:

- Todo list.
- Selected filters.
- Search query.
- Loading/error state.
- Save operation state.

### App/session state

Để Riverpod:

- Firebase auth state.
- Current user.
- Theme mode.
- App configuration.

---

# 8. Result and error model

Không để Firebase exception chạy xuyên toàn bộ application.

Thiết kế abstraction:

```dart
sealed class Failure {
  const Failure();
}

final class AuthFailure extends Failure {
  final String code;
}

final class PermissionFailure extends Failure {
  const PermissionFailure();
}

final class NetworkFailure extends Failure {
  const NetworkFailure();
}

final class ValidationFailure extends Failure {
  final String message;
}

final class UnknownFailure extends Failure {
  final Object error;
}
```

Repository map low-level exception → domain/application failure.

UI chỉ xử lý failure semantic:

```text
PermissionFailure
NetworkFailure
ValidationFailure
UnknownFailure
```

Không xử lý trực tiếp:

```text
FirebaseException(code: failed-precondition)
```

---

# 9. Firebase architecture

Firebase cung cấp Authentication, Firestore realtime/offline, Cloud Functions, Cloud Messaging, Crashlytics, Analytics và App Check cho Flutter. Firestore phù hợp cho Todo vì hỗ trợ realtime synchronization và offline access. 

## 9.1 Firebase services

### Required MVP

```text
Firebase Authentication
Cloud Firestore
Crashlytics
Analytics
App Check
```

### Later

```text
Firebase Cloud Messaging
Cloud Functions
Remote Config
Storage
```

## 9.2 Firebase project environments

Không dùng một Firebase project duy nhất cho mọi môi trường.

```text
Todo App
├── todo-dev
├── todo-staging
└── todo-prod
```

Mục tiêu:

- Dev không phá production.
- Rules test độc lập.
- Analytics production sạch.
- Có thể reset database dev.

---

# 10. Authentication architecture

Baseline:

```text
Email/Password
Google Sign-In
```

Có thể thêm Apple Sign-In ở phase release iOS.

## 10.1 Session flow

```text
App start
   ↓
Firebase.initializeApp
   ↓
Auth state listener
   ↓
┌───────────────┐
│ authenticated │───yes──→ App Shell
└───────┬───────┘
        │ no
        ▼
 Auth pages
```

## 10.2 Auth provider

```text
authStateProvider
    ↓
FirebaseAuthService
    ↓
FirebaseAuth
```

Không để ViewModel gọi FirebaseAuth trực tiếp.

## 10.3 User document

```text
/users/{uid}
```

Schema đề xuất:

```json
{
  "displayName": "Nguyen Van A",
  "email": "user@example.com",
  "photoUrl": null,
  "timezone": "Asia/Ho_Chi_Minh",
  "locale": "vi-VN",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

Không duplicate password hoặc sensitive authentication data vào Firestore.

---

# 11. Firestore data model

## 11.1 Data structure decision

Dùng user-scoped subcollections:

```text
users/{uid}
├── todos/{todoId}
│   └── subtasks/{subtaskId}
├── categories/{categoryId}
├── devices/{deviceId}
└── settings/main
```

Lý do:

- Security rule dễ giới hạn ownership theo `uid`.
- Dữ liệu của user tự nhiên nằm trong một namespace.
- Tránh mọi query phải nhớ thêm `where(userId == ...)`.
- Dễ tách shared/workspace model ở tương lai.

Firestore hỗ trợ documents, collections và subcollections; dữ liệu tăng trưởng theo thời gian phù hợp hơn khi không nhồi toàn bộ danh sách vào một document duy nhất. 

---

# 12. Todo schema

Path:

```text
/users/{uid}/todos/{todoId}
```

Schema:

```json
{
  "title": "Finish Flutter architecture",
  "description": "Complete technical design",
  "status": "active",
  "priority": "high",
  "categoryId": "work",
  "tags": ["flutter", "firebase"],
  "dueAt": "Timestamp|null",
  "reminderAt": "Timestamp|null",
  "completedAt": "Timestamp|null",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp",
  "subtaskCount": 3,
  "completedSubtaskCount": 1,
  "sortKey": 1000,
  "schemaVersion": 1
}
```

## 12.1 Field semantics

| Field | Type | Required | Note |
|---|---|---:|---|
| title | string | yes | Max 200 chars |
| description | string | no | Max 5000 chars |
| status | string | yes | `active`, `completed`, `archived` |
| priority | string | yes | `none`, `low`, `medium`, `high` |
| categoryId | string | no | Reference by ID |
| tags | array<string> | no | Max 20 tags |
| dueAt | timestamp | no | User selected date/time |
| reminderAt | timestamp | no | Exact local reminder moment stored as Timestamp |
| completedAt | timestamp | no | Null while active |
| createdAt | timestamp | yes | Server timestamp on create |
| updatedAt | timestamp | yes | Server timestamp on update |
| subtaskCount | number | yes | Denormalized |
| completedSubtaskCount | number | yes | Denormalized |
| sortKey | number | yes | Client ordering support |
| schemaVersion | number | yes | Migration support |

## 12.2 Status model

Do not use boolean only.

Use:

```text
active
completed
archived
```

Reason: future requirements thường cần distinguish completed khỏi archived/deleted.

Hard delete chỉ nên dùng khi user explicitly requests permanent delete.

---

# 13. Subtask data model

Path:

```text
/users/{uid}/todos/{todoId}/subtasks/{subtaskId}
```

Schema:

```json
{
  "title": "Implement Firestore repository",
  "completed": false,
  "sortOrder": 100,
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp",
  "schemaVersion": 1
}
```

Vì subtasks là danh sách tăng trưởng, dùng subcollection thay vì nhúng toàn bộ list vào Todo document.

---

# 14. Category data model

Path:

```text
/users/{uid}/categories/{categoryId}
```

Schema:

```json
{
  "name": "Work",
  "icon": "work",
  "colorKey": "blue",
  "sortOrder": 100,
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

Không lưu Flutter `Color` value trực tiếp làm business data.

Lưu semantic key:

```text
blue
red
green
purple
```

UI tự map key → color.

---

# 15. Device model

Path:

```text
/users/{uid}/devices/{deviceId}
```

Schema:

```json
{
  "platform": "android",
  "fcmToken": "...",
  "appVersion": "1.0.0",
  "timezone": "Asia/Ho_Chi_Minh",
  "lastSeenAt": "Timestamp"
}
```

Mục đích future:

- Push notification.
- Token refresh.
- Multi-device management.

FCM plugin cung cấp device registration token và token refresh stream; iOS còn có yêu cầu APNs token availability trước một số API calls. 

---

# 16. Query strategy

Todo list MVP nên ưu tiên những query đơn giản:

## 16.1 All active todos

```text
where status == active
orderBy updatedAt desc
```

## 16.2 Today's tasks

```text
where status == active
where dueAt >= startOfDay
where dueAt < startOfNextDay
orderBy dueAt asc
```

## 16.3 Completed

```text
where status == completed
orderBy completedAt desc
```

## 16.4 By category

```text
where status == active
where categoryId == :categoryId
orderBy dueAt asc
```

Firestore dùng index để phục vụ queries; các compound query/range/order combination có thể cần composite index. Khi thiếu index, Firestore cung cấp thông tin để tạo index tương ứng. 

Không tạo hàng loạt index trước khi có query thật.

---

# 17. Search architecture

Firestore không nên được coi là full-text search engine.

MVP:

```text
Load paginated/limited todo dataset
        ↓
Repository stream
        ↓
Client-side search/filter
```

Giới hạn dataset để tránh tải vô hạn.

Khi dataset lớn:

```text
Firestore
   ↓
Search service
   ├── Algolia
   ├── Typesense
   └── Elasticsearch/OpenSearch
```

Không thêm search engine vào MVP nếu chưa có evidence về nhu cầu.

---

# 18. Pagination

Todo list production phải hỗ trợ pagination.

Pattern:

```text
first page
  ↓
lastDocument
  ↓
startAfter(lastDocument)
  ↓
next page
```

Constants:

```text
pageSize = 30
```

Có thể thay đổi sau khi đo UX/performance thực tế.

---

# 19. Offline-first strategy

Cloud Firestore hỗ trợ đọc/ghi/listen/query dữ liệu từ cache khi offline và đồng bộ thay đổi khi thiết bị online lại. Trên Android/iOS offline persistence được bật mặc định; trên Web cần cấu hình persistence riêng. Khi nhiều thay đổi cùng document xảy ra, Firestore áp dụng last-write-wins. 

## 19.1 UX expectation

Khi offline:

```text
Create Todo
   ↓
UI cập nhật ngay
   ↓
Firestore local cache
   ↓
Network restored
   ↓
Sync server
```

Không bắt user chờ server response mới được thấy Todo.

## 19.2 Sync state

UI có thể phân biệt:

```text
synced
pending
failed
```

Không cần lưu `syncStatus` vào Firestore document nếu không cần. Có thể derive từ snapshot metadata/network state.

## 19.3 Conflict policy

MVP:

```text
Last write wins
```

Future nếu collaboration:

```text
server timestamp
version field
optimistic concurrency
conflict resolution
```

---

# 20. Repository contract

Ví dụ:

```dart
abstract interface class TodoRepository {
  Stream<List<Todo>> watchTodos(TodoQuery query);

  Future<Todo?> getTodo(String todoId);

  Future<String> createTodo(CreateTodoInput input);

  Future<void> updateTodo(String todoId, UpdateTodoInput input);

  Future<void> completeTodo(String todoId);

  Future<void> deleteTodo(String todoId);

  Future<void> restoreTodo(String todoId);
}
```

Repository interface không biết Firebase.

Không được xuất:

```dart
QuerySnapshot
DocumentSnapshot
DocumentReference
FirebaseException
```

ra khỏi data layer.

---

# 21. Data source contract

```dart
abstract interface class TodoDataSource {
  Stream<List<TodoDto>> watchTodos(TodoQueryDto query);

  Future<TodoDto?> getTodo(String todoId);

  Future<String> createTodo(TodoDto dto);

  Future<void> updateTodo(String todoId, Map<String, dynamic> data);

  Future<void> deleteTodo(String todoId);
}
```

Implementation:

```text
FirestoreTodoDataSource
       ↓
Cloud Firestore SDK
```

---

# 22. Entity vs DTO

## Domain entity

```dart
@freezed
class Todo with _$Todo {
  const factory Todo({
    required String id,
    required String title,
    required TodoStatus status,
    required TodoPriority priority,
    String? description,
    String? categoryId,
    @Default(<String>[]) List<String> tags,
    DateTime? dueAt,
    DateTime? reminderAt,
    DateTime? completedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int subtaskCount,
    required int completedSubtaskCount,
  }) = _Todo;
}
```

## DTO

DTO có thể chứa Firebase-specific mapping:

```text
Timestamp ↔ DateTime
```

Domain không import:

```dart
package:cloud_firestore/cloud_firestore.dart
```

---

# 23. ViewModel design

Mỗi feature page chính có một ViewModel chính.

Ví dụ:

```text
TodoListPage
   ↓
TodoListViewModel
```

ViewModel chịu trách nhiệm:

- Nhận user interaction.
- Validate input ở mức application.
- Gọi repository/use case.
- Quản lý async state.
- Expose state bất biến cho UI.

ViewModel không chịu trách nhiệm:

- Render UI.
- Firebase query syntax.
- Theme.
- Formatting toàn app.

---

# 24. Todo list state

State đề xuất:

```dart
@freezed
class TodoListState with _$TodoListState {
  const factory TodoListState({
    @Default(<Todo>[]) List<Todo> todos,
    @Default(TodoFilter()) TodoFilter filter,
    @Default('') String searchQuery,
    @Default(false) bool isRefreshing,
    @Default(false) bool isSaving,
    Failure? failure,
  }) = _TodoListState;
}
```

Async stream status nên được quản lý bằng Riverpod AsyncValue hoặc state abstraction phù hợp, tránh tự tạo quá nhiều boolean:

```text
isLoading
isSaving
isDeleting
isRefreshing
isError
```

Nếu state bắt đầu trở nên khó hiểu, tách operation state thành các provider riêng.

---

# 25. Filtering architecture

Tạo immutable filter object:

```text
TodoFilter
├── status
├── priority
├── categoryId
├── dueDateRange
└── tag
```

Pipeline:

```text
Firestore stream
      ↓
Todo collection
      ↓
filter
      ↓
search
      ↓
sort
      ↓
UI list
```

Những filter có thể làm hiệu quả ở server thì làm ở server.

Những logic presentation-only thì làm ở client.

---

# 26. Sorting strategy

Các mode:

```text
manual
created_desc
created_asc
due_asc
priority_desc
```

Manual ordering dùng `sortKey`.

Do Firestore không phải relational DB, không thiết kế kiểu “UPDATE tất cả task phía sau +1” cho mỗi drag/drop.

Dùng gap ordering:

```text
1000
2000
3000
```

Chèn giữa:

```text
1500
```

Periodic rebalance chỉ thực hiện khi khoảng cách quá nhỏ.

---

# 27. Reminder architecture

MVP nên dùng **local notification** cho reminder chính của chính thiết bị.

Reason:

- Reminder vẫn chạy khi backend không cần xử lý từng task.
- Không cần Cloud Function tạo timer cho từng task.
- Giảm cost và backend complexity.

Flow:

```text
User saves Todo
      ↓
TodoRepository.update
      ↓
ReminderService.schedule(todo)
```

Khi sửa due/reminder:

```text
cancel old notification
        ↓
create new notification
```

Khi complete:

```text
cancel reminder
```

FCM được dùng cho remote notification ở phase sau, không thay local scheduling cho mọi reminder cá nhân.

---

# 28. Notification ID strategy

Notification ID phải deterministic từ:

```text
todoId
```

Ví dụ hash → integer.

Mục tiêu:

```text
schedule(todo X)
→ update same notification
→ no duplicate notification
```

Không generate random ID mỗi lần schedule.

---

# 29. Timezone strategy

Firestore lưu timestamp theo instant UTC.

UI convert theo:

```text
device timezone
```

Profile có thể lưu:

```text
timezone = Asia/Ho_Chi_Minh
```

Không lưu local date string kiểu:

```text
"2026-09-30 10:00"
```

làm source of truth cho reminder.

---

# 30. Firebase Security Rules

Security Rules là lớp authorization chính cho client Firestore. Firebase khuyến nghị kết hợp Firebase Authentication với Firestore Security Rules để xây dựng access control theo user/role. Rules version 2 nên được dùng. 

## 30.1 Rule principle

User chỉ được:

```text
read/write /users/{ownUid}/...
```

User không được truy cập:

```text
/users/{otherUid}/...
```

## 30.2 Baseline rule

Pseudo-rule:

```text
rules_version = '2';

match /databases/{database}/documents {

  function isSignedIn() {
    return request.auth != null;
  }

  function isOwner(uid) {
    return isSignedIn() && request.auth.uid == uid;
  }

  match /users/{uid} {
    allow read, write: if isOwner(uid);

    match /todos/{todoId} {
      allow read, write: if isOwner(uid);

      match /subtasks/{subtaskId} {
        allow read, write: if isOwner(uid);
      }
    }

    match /categories/{categoryId} {
      allow read, write: if isOwner(uid);
    }

    match /devices/{deviceId} {
      allow read, write: if isOwner(uid);
    }

    match /settings/{document} {
      allow read, write: if isOwner(uid);
    }
  }
}
```

Actual rules phải thêm validation của field, type và immutable fields trước production.

## 30.3 Validation rules

MVP cần validate:

- title tồn tại.
- title là string.
- title không vượt giới hạn.
- status thuộc enum cho phép.
- priority thuộc enum cho phép.
- timestamps đúng type.
- createdAt không bị đổi tùy tiện.
- user không tự đổi ownership.
- không insert unexpected sensitive fields nếu schema contract đã khóa.

---

# 31. Firestore index policy

Version control file:

```text
firestore.indexes.json
```

Index chỉ thêm khi query thực tế yêu cầu.

Ví dụ dự kiến:

```text
collection: todos
fields:
  status ASC
  dueAt ASC
```

```text
collection: todos
fields:
  categoryId ASC
  status ASC
  dueAt ASC
```

Index definition phải được test trước khi deploy production.

---

# 32. Firebase configuration

Project cần có:

```text
firebase.json
.firebaserc
firestore.rules
firestore.indexes.json
firebase_options.dart
```

`firebase_options.dart` được tạo bằng FlutterFire CLI; official setup hướng dẫn chạy `flutterfire configure` và chạy lại khi thêm platform hoặc Firebase service mới. 

Không commit secret thật vào source nếu project có thêm backend credentials ngoài Firebase client configuration.

---

# 33. Bootstrap sequence

`main.dart` chỉ nên làm bootstrap.

```text
main()
 ↓
WidgetsFlutterBinding.ensureInitialized()
 ↓
configure dependencies
 ↓
Firebase.initializeApp()
 ↓
initialize Crashlytics
 ↓
initialize App Check
 ↓
initialize notification service
 ↓
runApp(App)
```

Không nhồi logic business vào `main.dart`.

---

# 34. Dependency injection

Riverpod làm DI container.

Ví dụ dependency graph:

```text
FirebaseFirestore provider
        ↓
FirestoreTodoDataSource
        ↓
TodoRepositoryImpl
        ↓
TodoListViewModel
```

Không cần thêm GetIt chỉ để làm DI nếu Riverpod đã đảm nhiệm concern này.

---

# 35. Router architecture

go_router được chọn vì hỗ trợ declarative routing, deep linking, redirects theo application state và shell routes. 

Routes baseline:

```text
/
/login
/register
/forgot-password
/app
/app/today
/app/inbox
/app/completed
/app/categories
/app/settings
/app/todo/:todoId
/app/todo/new
/app/category/:categoryId
```

## 35.1 Auth redirect

```text
not authenticated
 + protected route
 → /login

authenticated
 + auth route
 → /app/today
```

Router không tự gọi repository để fetch Todo.

Router chỉ quyết định navigation state.

---

# 36. App shell

App shell quản lý:

- Navigation.
- Shared scaffold.
- Theme.
- App-wide overlays.
- Global error feedback.

Các page feature không tự tạo một app shell khác.

---

# 37. Analytics design

Firebase Analytics dùng để đo hành vi product, không log raw sensitive content.

Event baseline:

```text
app_open
sign_up
login
logout
todo_created
todo_completed
todo_uncompleted
todo_deleted
todo_updated
reminder_created
reminder_completed
search_used
filter_used
```

Không gửi:

```text
todo.title
Todo.description
email nội dung riêng tư
```

Lý do: analytics cần product signal, không cần lưu nội dung cá nhân.

---

# 38. Crashlytics

Crashlytics dùng cho:

- Fatal crash.
- Non-fatal exception.
- Release health.
- Breadcrumb/context khi cần.

Firebase khuyến nghị kết hợp Analytics với Crashlytics để có breadcrumb logs giúp hiểu hành động trước crash. 

Custom keys nên là technical context:

```text
app_version
build_number
screen
feature
user_state
```

Không set user identity bằng dữ liệu nhạy cảm tùy tiện.

---

# 39. App Check

App Check dùng để tăng khả năng bảo vệ Firebase backend khỏi abuse/billing fraud/phishing-type misuse. 

Phase:

```text
DEV
→ monitor/log

STAGING
→ validate

PROD
→ enforce sau khi test đầy đủ
```

Không bật enforce production trước khi kiểm thử hết platform/build flavor.

---

# 40. Logging

Tạo wrapper:

```dart
abstract interface class AppLogger {
  void debug(String message, {Map<String, Object?> context});
  void info(String message, {Map<String, Object?> context});
  void warning(String message, {Map<String, Object?> context});
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, Object?> context,
  });
}
```

Rule:

- Debug log có thể nhiều trong dev.
- Production log phải có chủ đích.
- Không log password/token/private task content.

---

# 41. Validation

Input validation chia hai lớp.

## Client validation

Mục tiêu UX:

```text
empty title
too long title
invalid reminder
```

## Server rules validation

Mục tiêu security/data integrity.

Không được tin client validation.

---

# 42. Optimistic UI

Các thao tác nhanh nên optimistic:

```text
complete todo
uncomplete todo
change priority
```

Flow:

```text
User action
 ↓
local state changes
 ↓
repository write
 ↓
success → keep
failure → rollback + error
```

Firestore offline cache giúp mô hình này tự nhiên hơn trên supported platforms. 

---

# 43. Delete strategy

MVP:

```text
Delete
→ move to archived/soft-delete state
```

Permanent delete:

```text
Settings / Trash
→ Delete forever
```

Tuy nhiên có thể skip Trash ở MVP và dùng hard delete nếu product scope muốn tối giản. Kiến trúc repository phải giữ khả năng thay đổi chính sách này sau.

---

# 44. Concurrency and idempotency

Các command cần idempotent càng nhiều càng tốt.

Ví dụ:

```text
scheduleReminder(todoId)
```

gọi 2 lần không được sinh hai notification.

```text
completeTodo(todoId)
```

gọi lại không gây lỗi logic.

Trong các operation nhiều document, dùng Firestore transaction/batch khi invariants cần atomicity.

---

# 45. Atomic operations

Ví dụ complete Todo + cập nhật subtask count không nhất thiết phải là transaction trong mọi trường hợp.

Chỉ dùng transaction khi có invariant bắt buộc:

```text
completedSubtaskCount <= subtaskCount
```

Hoặc update cùng lúc nhiều documents phải nhất quán.

Không lạm dụng transaction vì tăng complexity.

---

# 46. Schema evolution

Mỗi document có:

```text
schemaVersion
```

Ví dụ:

```text
1 → MVP
2 → recurring support
3 → collaboration
```

Mapper phải chịu được field cũ/null/default.

Không assume mọi document production đã cập nhật ngay sau release.

---

# 47. Testing architecture

Testing pyramid:

```text
             E2E
            /  \
          Widget
         /      \
     Unit tests
```

## 47.1 Unit tests

Test:

- Todo validation.
- Filter.
- Sort.
- Date conversion.
- Repository mapping.
- Failure mapping.
- Reminder ID.

## 47.2 Provider/ViewModel tests

Test:

- initial state.
- create todo.
- complete todo.
- error state.
- retry.
- filter changes.

## 47.3 Widget tests

Test:

- list renders.
- empty state.
- error state.
- loading state.
- form validation.
- interaction.

## 47.4 Integration/E2E

Flow:

```text
launch
→ login
→ create todo
→ complete todo
→ restart
→ verify state persisted
```

Firebase Emulator Suite được ưu tiên cho integration/security testing để tránh test trực tiếp lên production Firebase.

---

# 48. Firebase Emulator strategy

Local development:

```text
Auth Emulator
Firestore Emulator
Functions Emulator (when needed)
```

Flow:

```text
Flutter dev
   ↓
Firebase Emulator Suite
```

CI chạy security rule tests against emulator.

Mục tiêu:

- Không ghi rác vào production.
- Test authorization.
- Test invalid payload.
- Test user isolation.

---

# 49. Security test cases

Bắt buộc phải có test cho:

```text
User A read User A data → allowed
User A write User A data → allowed
User A read User B data → denied
User A write User B data → denied
Unauthenticated read → denied
Unauthenticated write → denied
Invalid Todo status → denied
Invalid Todo priority → denied
Oversized title → denied
Ownership field mutation → denied
```

---

# 50. Performance strategy

## UI

- `const` càng nhiều càng tốt.
- List item nhỏ và rebuild có kiểm soát.
- Không chạy expensive computation trong `build`.
- Debounce search.
- Avoid rebuilding toàn page khi một Todo thay đổi.

## Firestore

- Limit query.
- Pagination.
- Chỉ select data cần thiết khi architecture/backend cho phép.
- Tránh listener trên collection khổng lồ.
- Index query thật.

## Images

Nếu có avatar/attachment sau này:

- Resize.
- Cache.
- Lazy load.
- Firebase Storage.

---

# 51. Search debounce

Search client:

```text
User types
   ↓
300 ms debounce
   ↓
apply filter
```

Không filter collection nặng ở mỗi keystroke.

Nếu search backend sau này:

```text
query
 ↓
debounce
 ↓
search service
```

---

# 52. Accessibility

Ngay từ technical layer phải hỗ trợ:

- Semantic labels.
- Touch target hợp lý.
- Dynamic text.
- Contrast.
- Keyboard navigation cho Web/Desktop future.
- Screen reader semantics.

Không hard-code logic chỉ phụ thuộc vị trí pixel.

---

# 53. Localization

Không hard-code text UI.

```text
lib/l10n/
```

Baseline:

```text
vi
 en
```

Date/time localization phải dùng locale-aware formatter.

Không dùng timezone string hard-coded trong UI.

---

# 54. Environment management

Có các build flavors:

```text
DEV
STAGING
PROD
```

Config:

```text
app name
bundle id/package name
Firebase project
logging level
analytics
app check
```

Không dùng:

```dart
if (kDebugMode) {
  Firebase project A
}
```

để quản lý toàn bộ environment.

---

# 55. CI/CD

CI minimum:

```text
flutter pub get
flutter analyze
flutter test
flutter test integration_test/...
flutter build ...
```

Pipeline:

```text
Pull Request
 ↓
format check
 ↓
analyze
 ↓
unit/widget tests
 ↓
security tests
 ↓
merge
 ↓
staging build
 ↓
manual QA
 ↓
production release
```

Production release cần giữ Firebase project đúng environment.

---

# 56. Git strategy

Branches:

```text
main
  ↑
develop
  ↑
feature/*
```

Commit style:

```text
feat: add todo creation
fix: handle offline todo update
refactor: separate firestore datasource
chore: update firebase config
 test: add todo repository tests
```

Không commit:

```text
.env secrets
private keys
local machine config
generated binaries
```

---

# 57. Documentation inside repository

Project root:

```text
README.md
ARCHITECTURE.md
CONTRIBUTING.md
```

Technical docs:

```text
docs/
├── architecture.md
├── firebase.md
├── firestore-schema.md
├── security.md
├── testing.md
└── release.md
```

Tài liệu này là master technical specification; khi implement có thể tách thành các file trên nếu project lớn.

---

# 58. Implementation phases

Đây là phase plan chính. Mỗi phase có output và Definition of Done riêng.

## PHASE 0 — Project bootstrap

### Mục tiêu

Tạo Flutter project chuẩn production.

### Công việc

- Tạo Flutter project.
- Chọn Android/iOS.
- Thiết lập lint.
- Thiết lập formatter.
- Thiết lập folder architecture.
- Thêm Riverpod.
- Thêm go_router.
- Thêm Freezed/json_serializable.
- Setup build_runner.

### Output

```text
Flutter app boots successfully.
```

### DoD

```text
flutter analyze = pass
flutter test = pass
flutter run = pass
```

---

## PHASE 1 — Firebase environment

### Công việc

- Tạo Firebase dev project.
- `flutterfire configure`.
- Firebase Core.
- Firebase Auth.
- Firestore.
- Emulator Suite.
- Rules baseline.
- Index baseline.

### DoD

App connect được dev Firebase và Emulator.

---

## PHASE 2 — App architecture foundation

### Công việc

- `App`.
- Theme.
- Router.
- Riverpod ProviderScope.
- Error model.
- Logger.
- Result abstraction nếu cần.
- Global async error handling.

### DoD

Có thể tạo feature giả:

```text
Home → Detail → Back
```

mà không phá architecture.

---

## PHASE 3 — Authentication

### Công việc

- Auth service.
- Auth repository.
- Email/password.
- Google login.
- Logout.
- Auth state provider.
- User profile creation.
- Route guards.

### DoD

```text
Register
Login
Logout
Restart app
Session restored
```

---

## PHASE 4 — Todo domain/data layer

### Công việc

- Todo entity.
- Todo DTO.
- Todo mapper.
- Repository interface.
- Firestore datasource.
- Repository implementation.
- Firestore paths.

### DoD

Repository test pass bằng fake/emulator.

---

## PHASE 5 — Todo CRUD

### Công việc

- Create.
- Read.
- Update.
- Delete.
- Complete.
- Uncomplete.
- Error handling.
- Optimistic interaction.

### DoD

Todo lifecycle chạy end-to-end.

---

## PHASE 6 — Todo list state

### Công việc

- Riverpod providers.
- ViewModel.
- Async states.
- Pagination.
- Realtime stream.
- Pull-to-refresh.

### DoD

List tự cập nhật realtime khi Firestore thay đổi.

---

## PHASE 7 — Category + tags

### Công việc

- Category CRUD.
- Assign category.
- Tags.
- Filter by category.
- Security Rules.

### DoD

Todo/category isolation đúng theo user.

---

## PHASE 8 — Search/filter/sort

### Công việc

- Search debounce.
- Filter object.
- Sort object.
- Derived providers.
- Pagination compatibility.

### DoD

Các combination filter chính hoạt động ổn định.

---

## PHASE 9 — Subtasks

### Công việc

- Subtask CRUD.
- Complete/uncomplete.
- Counters.
- Ordering.
- Todo detail integration.

### DoD

Counters không lệch.

---

## PHASE 10 — Reminder

### Công việc

- Notification service.
- Permission.
- Schedule.
- Reschedule.
- Cancel.
- Timezone.
- App restart rescheduling/verification.

### DoD

Reminder không duplicate.

---

## PHASE 11 — Offline-first

### Công việc

- Verify Firestore offline behavior.
- Offline UX.
- Pending state.
- Reconnect flow.
- Conflict behavior documentation.

### DoD

Test:

```text
offline create
offline update
offline complete
online sync
```

---

## PHASE 12 — Security hardening

### Công việc

- Rule validation.
- Field validation.
- Ownership validation.
- Emulator security tests.
- App Check.

### DoD

Negative security cases pass.

---

## PHASE 13 — Observability

### Công việc

- Analytics.
- Crashlytics.
- Error logging.
- Release version tagging.

### DoD

Có thể trả lời:

```text
Có crash gì?
Ở version nào?
Feature nào?
User flow nào trước crash?
```

---

## PHASE 14 — Testing hardening

### Công việc

- Unit.
- Widget.
- Provider/ViewModel.
- Integration.
- Firebase Rules tests.

### DoD

Core feature có regression coverage.

---

## PHASE 15 — Performance

### Công việc

- Rebuild analysis.
- Firestore query profiling.
- Pagination verification.
- Cold start check.
- Memory check.
- Large dataset testing.

### DoD

Không có obvious performance bottleneck trước release.

---

## PHASE 16 — Release readiness

### Công việc

- Staging Firebase.
- Production Firebase.
- Build flavors.
- App icons/name.
- Versioning.
- Release signing.
- Crashlytics verification.
- Analytics verification.
- App Check enforcement.
- Store metadata.

### DoD

Staging → production release có thể repeat được.

---

# 59. Suggested implementation order inside each feature

AI coding agent phải follow thứ tự:

```text
1. Domain entity
2. Domain repository interface
3. DTO
4. Datasource
5. Repository implementation
6. Provider / DI
7. ViewModel
8. Page
9. Widgets
10. Tests
11. Security rules
12. Indexes
13. Documentation
```

Không build UI đầu tiên rồi sau đó nhét Firebase logic vào Widget.

---

# 60. AI coding agent rules

Khi giao task cho AI coding agent:

1. Đọc toàn bộ `ARCHITECTURE.md` trước.
2. Không tự đổi architecture mà không document lý do.
3. Không thêm package nếu chưa có justification.
4. Không import Firebase SDK vào presentation/domain.
5. Không truy cập Firestore trực tiếp từ Widget.
6. Không dùng global mutable singleton cho business state.
7. Không bỏ qua tests cho business logic mới.
8. Không sửa Security Rules để “cho chạy được” mà không kiểm tra authorization.
9. Không hard-code Firebase collection path trong nhiều nơi.
10. Không duplicate business rule trong nhiều ViewModel.
11. Không dùng TODO/FIXME thay cho implementation của critical path.
12. Mọi feature mới phải có error/loading/empty state.

---

# 61. Example dependency graph

```text
App
 ├── Router
 │    └── AuthStateProvider
 │
 ├── TodoListPage
 │    └── TodoListViewModel
 │         └── TodoRepository
 │              └── FirestoreTodoDataSource
 │                   └── FirebaseFirestore
 │
 └── NotificationCoordinator
      └── NotificationService
```

---

# 62. Example Todo creation flow

```text
User
 ↓
TodoEditorPage
 ↓
TodoEditorViewModel
 ↓
validate input
 ↓
TodoRepository.createTodo()
 ↓
FirestoreTodoDataSource
 ↓
Cloud Firestore
 ↓
realtime snapshot
 ↓
TodoListProvider
 ↓
TodoListPage rebuild
```

Reminder:

```text
successful create
 ↓
ReminderService.schedule()
```

Không để page tự biết Firestore document path.

---

# 63. Example completion flow

```text
User taps complete
 ↓
TodoListViewModel.complete(todoId)
 ↓
TodoRepository.completeTodo(todoId)
 ↓
Firestore update
 ↓
ReminderService.cancel(todoId)
 ↓
Analytics.track(todo_completed)
 ↓
UI receives updated stream
```

Trong implementation thật, ordering giữa write/notification/analytics phải đảm bảo retry-safe.

---

# 64. Non-functional requirements

## Reliability

- Không crash khi Firebase request lỗi.
- Offline operation không làm mất UX state.
- Notification scheduling idempotent.

## Security

- Authenticated data isolation.
- Firestore rules deny-by-default.
- No secrets in client.
- App Check cho production.

## Maintainability

- Feature-first source tree.
- Explicit dependency direction.
- Testable repository interfaces.
- Minimal global state.

## Scalability

- Pagination.
- Subcollections cho child collections.
- Schema version.
- Environment separation.
- Search service được thay thế độc lập nếu cần.

---

# 65. What is intentionally NOT included in MVP

Không đưa vào MVP nếu chưa có requirement:

```text
Team collaboration
Workspace permissions
Real-time shared editing
AI assistant
Attachments
Advanced calendar sync
Complex recurring rule engine
Billing/subscription
Admin CMS
Server-side full-text search
```

Các capability trên có thể làm thay đổi data model và backend architecture đáng kể, nên chỉ activate khi product requirement được chốt.

---

# 66. Architecture checkpoints

Sau mỗi phase lớn cần review:

```text
PHASE 2
Architecture checkpoint

PHASE 5
Data + CRUD checkpoint

PHASE 10
Notification/offline checkpoint

PHASE 12
Security checkpoint

PHASE 14
Testing checkpoint

PHASE 16
Release checkpoint
```

Không đợi tới release mới kiểm tra architecture.

---

# 67. Definition of Done — Whole MVP

MVP được xem là hoàn thành khi:

```text
[ ] Flutter app builds
[ ] Dev/Staging/Prod environments separated
[ ] Authentication works
[ ] Session restore works
[ ] Todo CRUD works
[ ] Complete/uncomplete works
[ ] Category works
[ ] Search works
[ ] Filter works
[ ] Sort works
[ ] Subtasks work
[ ] Reminder works
[ ] Offline create/update works
[ ] Reconnect sync works
[ ] Firestore security rules tested
[ ] Firebase App Check configured
[ ] Crashlytics verified
[ ] Analytics verified
[ ] Unit tests exist
[ ] Widget tests exist
[ ] Integration tests exist
[ ] CI pipeline passes
[ ] Production build reproducible
```

---

# 68. Recommended first implementation slice

Không triển khai toàn bộ 16 phase một lần.

Slice đầu tiên chỉ cần:

```text
PHASE 0
 ↓
PHASE 1
 ↓
PHASE 2
 ↓
PHASE 3
 ↓
PHASE 4
 ↓
PHASE 5
```

Kết quả cuối slice:

```text
Register/Login
    ↓
Todo List
    ↓
Create Todo
    ↓
Edit Todo
    ↓
Complete Todo
    ↓
Delete Todo
    ↓
Firebase persistence
```

Sau slice này mới triển khai Category/Search/Subtask/Reminder/Offline hardening.

---

# 69. Technical decisions summary

```text
Architecture
Feature-first + MVVM + Repository/Service

State
Riverpod 3

Navigation
go_router

Database
Cloud Firestore

Auth
Firebase Authentication

Realtime
Firestore snapshots

Offline
Firestore offline persistence

Notifications
Local notifications first
FCM later for remote events

Security
Firebase Auth + Firestore Rules + App Check

Observability
Crashlytics + Analytics + AppLogger

Testing
Unit + Widget + Integration + Emulator Rules

Deployment
Firebase dev/staging/prod

Scalability
Pagination + subcollections + schemaVersion
```

---

# 70. Reference sources

Các quyết định Firebase/Flutter trong tài liệu được đối chiếu với tài liệu chính thức và package registry tại thời điểm 2026-09-30:

- Flutter App Architecture: https://docs.flutter.dev/app-architecture/guide
- Firebase for Flutter: https://firebase.google.com/docs/flutter
- FlutterFire setup: https://firebase.google.com/docs/flutter/setup
- Cloud Firestore data structure: https://firebase.google.com/docs/firestore/manage-data/structure-data
- Firestore offline: https://firebase.google.com/docs/firestore/manage-data/enable-offline
- Firestore Security Rules: https://firebase.google.com/docs/firestore/security/get-started
- Firestore indexes: https://firebase.google.com/docs/firestore/query-data/indexing
- Firebase Cloud Messaging for Flutter: https://firebase.google.com/docs/cloud-messaging/flutter/get-started
- Firebase Crashlytics for Flutter: https://firebase.google.com/docs/crashlytics/flutter/get-started
- Firebase App Check for Flutter: https://firebase.google.com/docs/app-check/flutter
- flutter_local_notifications: https://pub.dev/packages/flutter_local_notifications
- Riverpod: https://pub.dev/packages/flutter_riverpod
- go_router: https://pub.dev/packages/go_router
- Freezed: https://pub.dev/packages/freezed
- json_serializable: https://pub.dev/packages/json_serializable

---

# 71. Next document

Sau khi technical architecture này được chốt, tài liệu kế tiếp cần thiết kế riêng:

```text
UI_UX_SPEC.md
```

Sau đó:

```text
STITCH_PROMPTS.md
```

`STITCH_PROMPTS.md` sẽ mô tả từng screen, design system, component states, responsive behavior, user flows và prompt theo từng màn hình để đưa vào Google Stitch.
