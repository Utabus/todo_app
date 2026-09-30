import 'dart:async';
import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  UserEntity? _currentUser = const UserEntity(
    id: 'u1',
    email: 'alex.morgan@company.com',
    displayName: 'Alex Morgan',
    photoUrl: null,
    timezone: 'Asia/Ho_Chi_Minh',
    locale: 'en-US',
  );

  final _controller = StreamController<UserEntity?>.broadcast();

  AuthRepositoryImpl() {
    _emit();
  }

  void _emit() {
    _controller.add(_currentUser);
  }

  @override
  Stream<UserEntity?> authStateChanges() => _controller.stream;

  @override
  UserEntity? get currentUser => _currentUser;

  @override
  Future<Result<UserEntity, Failure>> signInWithEmail(String email, String password) async {
    if (email.trim().isEmpty || !email.contains('@')) {
      return const Error(ValidationFailure('Please enter a valid email address'));
    }
    if (password.length < 6) {
      return const Error(ValidationFailure('Password must be at least 6 characters'));
    }

    _currentUser = UserEntity(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      email: email.trim(),
      displayName: email.split('@').first,
    );
    _emit();
    return Success(_currentUser!);
  }

  @override
  Future<Result<UserEntity, Failure>> signUpWithEmail(String email, String password, String displayName) async {
    if (displayName.trim().isEmpty) {
      return const Error(ValidationFailure('Please enter your full name'));
    }
    if (email.trim().isEmpty || !email.contains('@')) {
      return const Error(ValidationFailure('Please enter a valid email address'));
    }
    if (password.length < 6) {
      return const Error(ValidationFailure('Password must be at least 6 characters'));
    }

    _currentUser = UserEntity(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      email: email.trim(),
      displayName: displayName.trim(),
    );
    _emit();
    return Success(_currentUser!);
  }

  @override
  Future<Result<void, Failure>> signOut() async {
    _currentUser = null;
    _emit();
    return const Success(null);
  }
}
