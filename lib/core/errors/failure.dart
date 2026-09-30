/// Sealed Failure hierarchy representing domain & application level failures
sealed class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

final class AuthFailure extends Failure {
  final String code;
  const AuthFailure(super.message, {this.code = 'auth_error'});
}

final class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission denied']);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network connection unavailable']);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class UnknownFailure extends Failure {
  final Object? error;
  const UnknownFailure([super.message = 'An unexpected error occurred', this.error]);
}
