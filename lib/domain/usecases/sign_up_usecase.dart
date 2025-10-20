import 'package:todo/domain/entities/user_entity.dart';
import 'package:todo/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repo;
  SignUpUseCase(this.repo);

  Future<UserEntity?> call(String email, String password) {
    return repo.signUp(email: email, password: password);
  }
}
