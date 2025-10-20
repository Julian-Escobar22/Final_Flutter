import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:todo/presentation/widgets/app_navbar.dart';
import 'package:todo/presentation/widgets/particle_background.dart';
import 'package:todo/presentation/widgets/app_footer.dart';
import 'package:todo/presentation/routes.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _p1 = TextEditingController();
  final _p2 = TextEditingController();
  bool _ob1 = true;
  bool _ob2 = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _ensureRecoverySession();
  }

  @override
  void dispose() {
    _p1.dispose();
    _p2.dispose();
    super.dispose();
  }

  /// Recupera la sesión desde la URL del enlace de Supabase
  Future<void> _ensureRecoverySession() async {
    final sb = Supabase.instance.client;

    if (sb.auth.currentSession != null) return;

    final uri = Uri.base;
    try {
      // Intenta recuperar sesión directamente (maneja ?code o #access_token)
      await sb.auth.getSessionFromUrl(uri);
      _showSnack('Sesión de recuperación establecida correctamente.');
      return;
    } catch (e) {
      // Si getSessionFromUrl falla, intenta intercambio manual de código
      final code = uri.queryParameters['code'];
      if (code != null) {
        try {
          await sb.auth.exchangeCodeForSession(code);
          _showSnack('Sesión de recuperación establecida correctamente.');
          return;
        } catch (_) {}
      }
    }

    // Si todo falla, muestra error claro
    _showSnack(
      'Enlace inválido o expirado. Solicita nuevamente el correo.',
      isError: true,
    );
  }

  /// Guardar nueva contraseña
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final sb = Supabase.instance.client;
    final session = sb.auth.currentSession;
    if (session == null) {
      _showSnack(
        'Enlace inválido o expirado. Solicita nuevamente el correo.',
        isError: true,
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await sb.auth.updateUser(UserAttributes(password: _p1.text.trim()));
      _showSnack('Contraseña actualizada. Inicia sesión con tu nueva clave.');
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      final msg = e.toString();
      _showSnack(
        msg.contains('session missing')
            ? 'Enlace inválido o expirado. Solicita nuevamente el correo.'
            : 'No se pudo actualizar la contraseña. Intenta de nuevo.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Mostrar SnackBar de forma segura
  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final isSmall = w < 700;
        final maxCard = isSmall ? w - 24 : 480.0;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F0FF),
          appBar: const AppNavbar(),
          body: Stack(
            children: [
              const ParticleBackground(
                count: 80,
                alpha: 0.12,
                speed: 0.12,
                sizeMin: 1.0,
                sizeMax: 3.0,
              ),
              Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmall ? 12 : 24,
                          vertical: isSmall ? 12 : 36,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxCard),
                          child: Card(
                            color: const Color(0xfff9f6ff),
                            elevation: 8,
                            shadowColor: Colors.black12,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxHeight: 160,
                                      ),
                                      child: Lottie.asset(
                                        'assets/lottie/reset_password.json',
                                        repeat: true,
                                        frameRate: FrameRate.max,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Restablecer contraseña',
                                      style: theme.textTheme.titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Ingresa tu nueva contraseña y confírmala.',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 18),

                                    // Nueva contraseña
                                    TextFormField(
                                      controller: _p1,
                                      obscureText: _ob1,
                                      decoration: InputDecoration(
                                        labelText: 'Nueva contraseña',
                                        prefixIcon: const Icon(
                                          Icons.password_rounded,
                                        ),
                                        suffixIcon: IconButton(
                                          onPressed: () =>
                                              setState(() => _ob1 = !_ob1),
                                          icon: Icon(
                                            _ob1
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                          ),
                                        ),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.isEmpty)
                                          return 'Ingresa tu contraseña';
                                        if (v.length < 6)
                                          return 'Mínimo 6 caracteres';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12),

                                    // Confirmar contraseña
                                    TextFormField(
                                      controller: _p2,
                                      obscureText: _ob2,
                                      decoration: InputDecoration(
                                        labelText: 'Confirmar contraseña',
                                        prefixIcon: const Icon(
                                          Icons.lock_outline,
                                        ),
                                        suffixIcon: IconButton(
                                          onPressed: () =>
                                              setState(() => _ob2 = !_ob2),
                                          icon: Icon(
                                            _ob2
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                          ),
                                        ),
                                      ),
                                      validator: (v) {
                                        if (v == null || v.isEmpty)
                                          return 'Confirma tu contraseña';
                                        if (v != _p1.text)
                                          return 'Las contraseñas no coinciden';
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 18),

                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton(
                                        onPressed: _loading ? null : _submit,
                                        child: _loading
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : const Text(
                                                'Guardar nueva contraseña',
                                              ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextButton(
                                      onPressed: _loading
                                          ? null
                                          : () => Get.offAllNamed(
                                              AppRoutes.login,
                                            ),
                                      child: const Text(
                                        'Volver a iniciar sesión',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const AppFooter(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
