import 'package:todo/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> signIn({required String email, required String password});
  Future<UserEntity?> signUp({required String email, required String password});
  Future<void> signOut();
  Future<UserEntity?> currentUser();
}
