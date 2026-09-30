class RouteNames {
  static const String signIn = '/signin';
  static const String signUp = '/signup';
  static const String today = '/today';
  static const String tasks = '/tasks';
  static const String search = '/search';
  static const String settings = '/settings';
  static const String taskDetail = '/tasks/:id';
  static const String categories = '/categories';
  static const String notifications = '/notifications';

  static String taskDetailPath(String id) => '/tasks/$id';
}
