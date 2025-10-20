import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  bool get isLoggedIn => user.value != null;

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

  // ----- utilidades directas de Supabase para flows de email -----

  // AuthController.dart
  Future<void> resetPassword(String email, {String? redirectTo}) async {
    final sb = Supabase.instance.client;

    // http://localhost:55647
    final base = Uri.base;
    final origin =
        '${base.scheme}://${base.host}${(base.hasPort && base.port != 80 && base.port != 443) ? ':${base.port}' : ''}';

    final webRedirect = '$origin/#/reset'; 

    await sb.auth.resetPasswordForEmail(
      email,
      redirectTo: redirectTo ?? webRedirect,
    );
  }

  Future<void> resendConfirmation(String email) async {
    final sb = Supabase.instance.client;
    await sb.auth.resend(type: OtpType.signup, email: email);
  }

  String _mapError(Object e) {
    final msg = e.toString();
    if (msg.contains('Invalid login credentials'))
      return 'Credenciales inválidas';
    if (msg.contains('Email not confirmed'))
      return 'Tu email no está confirmado';
    if (msg.contains('User already registered'))
      return 'Ese correo ya está registrado';
    return 'Ocurrió un error. Intenta de nuevo';
  }
}
