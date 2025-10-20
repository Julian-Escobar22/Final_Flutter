import 'package:todo/domain/entities/user_entity.dart';
import 'package:todo/domain/repositories/auth_repository.dart';

class SignInUseCase {
  final AuthRepository repo;
  SignInUseCase(this.repo);

  Future<UserEntity?> call(String email, String password) {
    return repo.signIn(email: email, password: password);
  }
}
