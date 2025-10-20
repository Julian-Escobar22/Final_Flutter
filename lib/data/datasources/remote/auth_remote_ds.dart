import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo/domain/entities/user_entity.dart';

class AuthRemoteDs {
  final SupabaseClient client;
  AuthRemoteDs(this.client);

  Future<UserEntity?> signIn(String email, String password) async {
    final res = await client.auth.signInWithPassword(email: email, password: password);
    final user = res.user;
    if (user == null) return null;
    return UserEntity(id: user.id, email: user.email ?? '');
  }

  Future<UserEntity?> signUp(String email, String password) async {
    final res = await client.auth.signUp(email: email, password: password);
    final user = res.user;
    if (user == null) return null;
    return UserEntity(id: user.id, email: user.email ?? '');
  }

  Future<void> signOut() => client.auth.signOut();

  Future<UserEntity?> currentUser() async {
    final user = client.auth.currentUser;
    if (user == null) return null;
    return UserEntity(id: user.id, email: user.email ?? '');
  }
}
