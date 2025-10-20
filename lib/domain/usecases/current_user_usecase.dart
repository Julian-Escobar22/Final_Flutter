import 'package:todo/domain/entities/user_entity.dart';
import 'package:todo/domain/repositories/auth_repository.dart';

class CurrentUserUseCase {
  final AuthRepository repo;
  CurrentUserUseCase(this.repo);

  Future<UserEntity?> call() => repo.currentUser();
}
