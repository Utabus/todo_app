/// Firestore collection & document path constants based on Section 11 of technical spec
class FirestoreConstants {
  static const String usersCollection = 'users';
  static const String todosSubcollection = 'todos';
  static const String subtasksSubcollection = 'subtasks';
  static const String categoriesSubcollection = 'categories';
  static const String settingsSubcollection = 'settings';

  static String userPath(String uid) => '$usersCollection/$uid';
  static String todosPath(String uid) => '${userPath(uid)}/$todosSubcollection';
  static String todoDocPath(String uid, String todoId) => '${todosPath(uid)}/$todoId';
  static String subtasksPath(String uid, String todoId) => '${todoDocPath(uid, todoId)}/$subtasksSubcollection';
  static String categoriesPath(String uid) => '${userPath(uid)}/$categoriesSubcollection';
  static String settingsPath(String uid) => '${userPath(uid)}/$settingsSubcollection/main';
}
