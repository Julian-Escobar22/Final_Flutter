import 'package:get/get.dart';
import 'package:todo/domain/entities/user_entity.dart';
import 'package:todo/domain/usecases/current_user_usecase.dart';
import 'package:todo/domain/usecases/sign_in_usecase.dart';
import 'package:todo/domain/usecases/sign_out_usecase.dart';
import 'package:todo/domain/usecases/sign_up_usecase.dart';

class AuthController extends GetxController {
  final SignInUseCase signIn;
  final SignUpUseCase signUp;
  final SignOutUseCase signOut;
  final CurrentUserUseCase currentUser;

  AuthController({
    required this.signIn,
    required this.signUp,
    required this.signOut,
    required this.currentUser,
  });

  final RxBool loading = false.obs;
  final RxnString error = RxnString();
  final Rxn<UserEntity> user = Rxn<UserEntity>();

  Future<bool> doSignIn(String email, String password) async {
    loading.value = true;
    error.value = null;
    try {
      final u = await signIn(email, password);
      user.value = u;
      return u != null;
    } catch (e) {
      error.value = _mapError(e);
      return false;
    } finally {
      loading.value = false;
    }
  }

  Future<bool> doSignUp(String email, String password) async {
    loading.value = true;
    error.value = null;
    try {
      final u = await signUp(email, password);
      user.value = u;
      return u != null;
    } catch (e) {
      error.value = _mapError(e);
      return false;
    } finally {
      loading.value = false;
    }
  }

  Future<void> doSignOut() async {
    await signOut();
    user.value = null;
  }

  Future<void> loadSession() async {
    user.value = await currentUser();
  }

  String _mapError(Object e) {
    final msg = e.toString();
    if (msg.contains('Invalid login credentials')) {
      return 'Credenciales inválidas';
    }
    if (msg.contains('User already registered')) {
      return 'Ese correo ya está registrado';
    }
    return 'Ocurrió un error. Intenta de nuevo';
    
  }
}
