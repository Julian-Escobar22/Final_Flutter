import 'package:todo/data/datasources/remote/auth_remote_ds.dart';
import 'package:todo/domain/entities/user_entity.dart';
import 'package:todo/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDs remote;
  AuthRepositoryImpl(this.remote);

  @override
  Future<UserEntity?> signIn({required String email, required String password}) async {
    try {
      return await remote.signIn(email, password);
    } on Object {
      rethrow;
    }
  }

  @override
  Future<UserEntity?> signUp({required String email, required String password}) async {
    try {
      return await remote.signUp(email, password);
    } on Object {
      rethrow;
    }
  }

  @override
  Future<void> signOut() => remote.signOut();

  @override
  Future<UserEntity?> currentUser() => remote.currentUser();
}
