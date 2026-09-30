import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/categories/presentation/pages/category_page.dart';
import '../../features/notifications/presentation/pages/notification_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/todos/presentation/pages/today_page.dart';
import '../../features/todos/presentation/pages/todo_detail_page.dart';
import '../../features/todos/presentation/pages/todo_list_page.dart';
import 'main_scaffold_shell.dart';
import 'route_names.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.today,
    routes: [
      // Auth routes
      GoRoute(
        path: RouteNames.signIn,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: RouteNames.signUp,
        builder: (context, state) => const SignUpPage(),
      ),

      // App Shell routes (Bottom Navigation Bar)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffoldShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.today,
                builder: (context, state) => const TodayPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.tasks,
                builder: (context, state) => const TodoListPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.search,
                builder: (context, state) => const SearchPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),

      // Detail & Secondary routes
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.taskDetail,
        builder: (context, state) {
          final taskId = state.pathParameters['id'] ?? '';
          return TodoDetailPage(taskId: taskId);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.categories,
        builder: (context, state) => const CategoryPage(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RouteNames.notifications,
        builder: (context, state) => const NotificationPage(),
      ),
    ],
  );
});
