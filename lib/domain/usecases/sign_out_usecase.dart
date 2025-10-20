import 'package:todo/domain/repositories/auth_repository.dart';

class SignOutUseCase {
  final AuthRepository repo;
  SignOutUseCase(this.repo);

  Future<void> call() => repo.signOut();
}
