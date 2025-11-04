import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseHelper {
  static SupabaseClient get client => Supabase.instance.client;
}
