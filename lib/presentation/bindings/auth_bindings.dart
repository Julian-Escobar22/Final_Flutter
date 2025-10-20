import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:todo/core/config/supabase_config.dart';

import 'package:todo/data/datasources/remote/auth_remote_ds.dart';
import 'package:todo/data/repositories/auth_repository_impl.dart';

import 'package:todo/domain/repositories/auth_repository.dart';
import 'package:todo/domain/usecases/current_user_usecase.dart';
import 'package:todo/domain/usecases/sign_in_usecase.dart';
import 'package:todo/domain/usecases/sign_out_usecase.dart';
import 'package:todo/domain/usecases/sign_up_usecase.dart';

import 'package:todo/presentation/controllers/auth_controller.dart';

class AuthBindings extends Bindings {
  @override
  void dependencies() {
    // Cliente de Supabase (ya inicializado en main)
    final SupabaseClient client = SupabaseConfig.client;

    // DataSource remoto
    Get.lazyPut<AuthRemoteDs>(() => AuthRemoteDs(client));

    // 🔧 Repositorio: registrar usando la INTERFAZ
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(Get.find<AuthRemoteDs>()),
    );

    // Use cases (reciben AuthRepository)
    Get.lazyPut<SignInUseCase>(() => SignInUseCase(Get.find<AuthRepository>()));
    Get.lazyPut<SignUpUseCase>(() => SignUpUseCase(Get.find<AuthRepository>()));
    Get.lazyPut<SignOutUseCase>(
      () => SignOutUseCase(Get.find<AuthRepository>()),
    );
    Get.lazyPut<CurrentUserUseCase>(
      () => CurrentUserUseCase(Get.find<AuthRepository>()),
    );

    // Controller
    Get.put<AuthController>(
      AuthController(
        signIn: Get.find<SignInUseCase>(),
        signUp: Get.find<SignUpUseCase>(),
        signOut: Get.find<SignOutUseCase>(),
        currentUser: Get.find<CurrentUserUseCase>(),
      ),
    );
  }
}
