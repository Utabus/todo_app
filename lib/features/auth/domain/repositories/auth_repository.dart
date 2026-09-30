import '../../../../core/errors/failure.dart';
import '../../../../core/result/result.dart';
import '../entities/user_entity.dart';

abstract interface class AuthRepository {
  Stream<UserEntity?> authStateChanges();
  UserEntity? get currentUser;
  Future<Result<UserEntity, Failure>> signInWithEmail(String email, String password);
  Future<Result<UserEntity, Failure>> signUpWithEmail(String email, String password, String displayName);
  Future<Result<void, Failure>> signOut();
}
