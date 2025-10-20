// lib/presentation/bindings/auth_bindings.dart
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// DATA
import 'package:todo/data/datasources/remote/auth_remote_ds.dart';
import 'package:todo/data/repositories/auth_repository_impl.dart';

// DOMAIN
import 'package:todo/domain/repositories/auth_repository.dart';
import 'package:todo/domain/usecases/sign_in_usecase.dart';
import 'package:todo/domain/usecases/sign_up_usecase.dart';
import 'package:todo/domain/usecases/sign_out_usecase.dart';
import 'package:todo/domain/usecases/current_user_usecase.dart';

// CONTROLLER
import 'package:todo/presentation/controllers/auth_controller.dart';

class AuthBindings extends Bindings {
  @override
  void dependencies() {
    // ---------- DATASOURCE ----------
    // Ajusta el nombre si tu clase se llama distinto (p.ej. SupabaseAuthRemoteDs)
    Get.lazyPut<AuthRemoteDs>(
      () => AuthRemoteDs(Supabase.instance.client),
      fenix: true,
    );

    // ---------- REPOSITORY ----------
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(Get.find<AuthRemoteDs>()),
      fenix: true,
    );

    // ---------- USECASES ----------
    Get.lazyPut<SignInUseCase>(
      () => SignInUseCase(Get.find<AuthRepository>()),
      fenix: true,
    );
    Get.lazyPut<SignUpUseCase>(
      () => SignUpUseCase(Get.find<AuthRepository>()),
      fenix: true,
    );
    Get.lazyPut<SignOutUseCase>(
      () => SignOutUseCase(Get.find<AuthRepository>()),
      fenix: true,
    );
    Get.lazyPut<CurrentUserUseCase>(
      () => CurrentUserUseCase(Get.find<AuthRepository>()),
      fenix: true,
    );

    // ---------- CONTROLLER ----------
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(
        AuthController(
          signIn: Get.find<SignInUseCase>(),
          signUp: Get.find<SignUpUseCase>(),
          signOut: Get.find<SignOutUseCase>(),
          currentUser: Get.find<CurrentUserUseCase>(),
        ),
        permanent: true,
      );
    }
  }
}
