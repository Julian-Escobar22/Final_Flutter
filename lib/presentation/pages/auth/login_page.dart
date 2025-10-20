import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:todo/presentation/widgets/app_navbar.dart';
import 'package:todo/presentation/utils/lottie_transition.dart';
import 'package:todo/presentation/routes.dart';
import 'package:todo/presentation/widgets/particle_background.dart';
import 'package:todo/presentation/widgets/app_footer.dart';
import 'package:todo/presentation/controllers/auth_controller.dart';
import 'package:todo/presentation/utils/dialogs.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final isSmall = w < 700;
        final maxCard = isSmall ? w - 24 : 440.0;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F0FF),
          appBar: const AppNavbar(authMode: NavbarAuthMode.login),
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
                          child: const _LoginCard(),
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

class _LoginCard extends StatefulWidget {
  const _LoginCard();

  @override
  State<_LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  // GetX controller (inyectado por AuthBindings)
  late final AuthController _auth = Get.find<AuthController>();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _resendConfirmation(String email) async {
    try {
      await Supabase.instance.client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      if (!mounted) return;
      await showSuccessDialog(
        context,
        title: 'Correo reenviado',
        message:
            'Te enviamos un nuevo enlace de confirmación a $email. Revisa tu bandeja de entrada o spam.',
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      await showErrorDialog(
        context,
        title: 'No se pudo reenviar',
        message: e.message,
      );
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _email.text.trim();
    final pass = _password.text;

    // marca loading desde el controller
    _auth.loading.value = true;
    final ok = await _auth.doSignIn(email, pass);
    if (!mounted) return;
    _auth.loading.value = false;

    if (ok) {
      await showSuccessDialog(
        context,
        title: '¡Bienvenido!',
        message: 'Inicio de sesión correcto.',
        onOk: () => Get.offAllNamed(AppRoutes.home), // luego /home real
      );
      return;
    }

    // lee mensaje de error expuesto por el controller
    final err = (_auth.error.value ?? 'Error al iniciar sesión').toLowerCase();

    // Heurística para el caso "email no confirmado"
    final isNotConfirmed =
        err.contains('not confirmed') ||
        err.contains('no confirm') ||
        err.contains('email_not_confirmed');

    if (isNotConfirmed) {
      await showEmailNotConfirmedDialog(
        context,
        email: email,
        onResend: () => _resendConfirmation(email),
      );
      return;
    }

    await showErrorDialog(
      context,
      title: 'No se pudo iniciar sesión',
      message: _auth.error.value ?? 'Intenta nuevamente.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: const Color(0xfff9f6ff),
      elevation: 8,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 160),
                child: Lottie.asset(
                  'assets/lottie/login.json',
                  repeat: true,
                  frameRate: FrameRate.max,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bienvenido de nuevo',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Inicia sesión para continuar',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),

              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  prefixIcon: Icon(Icons.alternate_email),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa tu correo';
                  final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim());
                  if (!ok) return 'Correo inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _password,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                  if (v.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    final controller = TextEditingController(
                      text: _email.text.trim(),
                    );
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Restablecer contraseña'),
                        content: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            labelText: 'Correo',
                            prefixIcon: Icon(Icons.alternate_email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Enviar'),
                          ),
                        ],
                      ),
                    );

                    if (ok == true) {
                      final mail = controller.text.trim();
                      if (mail.isEmpty) return;
                      try {
                        await _auth.resetPassword(
                          mail,
                          // 👇 si quieres volver al login después del enlace
                          redirectTo:
                              'http://localhost:55647/#/reset', // ajusta a tu puerto actual
                        );
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Te enviamos un correo para restablecer tu contraseña',
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No se pudo enviar: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => FilledButton(
                    onPressed: _auth.loading.value ? null : _submit,
                    child: _auth.loading.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Ingresar'),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes cuenta?'),
                  TextButton(
                    onPressed: () => LottieScreenTransition.playAndNavigate(
                      context,
                      asset: 'assets/lottie/intro-login.json',
                      routeName: AppRoutes.register,
                      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                      speedMultiplier: 4.0,
                    ),
                    child: const Text('Crear una cuenta'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
