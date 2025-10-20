import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo/presentation/widgets/app_navbar.dart';
import 'package:todo/presentation/utils/lottie_transition.dart';
import 'package:todo/presentation/routes.dart';
import 'package:todo/presentation/widgets/particle_background.dart';
import 'package:todo/presentation/widgets/app_footer.dart';
import 'package:todo/presentation/utils/dialogs.dart'; // 👈 ADICIÓN

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final isSmall = w < 700;
        final maxCard = isSmall ? w - 24 : 480.0;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F0FF),
          appBar: const AppNavbar(authMode: NavbarAuthMode.register),
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
                          child: const _RegisterCard(),
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

class _RegisterCard extends StatefulWidget {
  const _RegisterCard();

  @override
  State<_RegisterCard> createState() => _RegisterCardState();
}

class _RegisterCardState extends State<_RegisterCard> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
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
        message: 'Te enviamos un nuevo enlace de confirmación a $email.',
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

    setState(() => _loading = true);
    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: pass,
      );

      if (!mounted) return;
      setState(() => _loading = false);

      // Siempre mostramos instrucción de confirmación (aunque tengas confirmación desactivada en dev)
      await showEmailConfirmationSentDialog(
        context,
        email: email,
        onResend: () => _resendConfirmation(email),
      );

      // Opcional: ir al login luego del OK
      // ignore: use_build_context_synchronously
      LottieScreenTransition.playAndNavigate(
        context,
        asset: 'assets/lottie/intro-login.json',
        routeName: AppRoutes.login,
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        speedMultiplier: 4.0,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      await showErrorDialog(
        context,
        title: 'No se pudo crear la cuenta',
        message: e.message,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      await showErrorDialog(
        context,
        title: 'Error inesperado',
        message: 'Intenta de nuevo.',
      );
    }
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
                  'assets/lottie/register-animation.json',
                  repeat: true,
                  frameRate: FrameRate.max,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Crea tu cuenta',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'Regístrate para empezar a estudiar mejor',
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
                obscureText: _obscure1,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
                    icon: Icon(_obscure1 ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                  if (v.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _confirm,
                obscureText: _obscure2,
                decoration: InputDecoration(
                  labelText: 'Confirmar contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                    icon: Icon(_obscure2 ? Icons.visibility : Icons.visibility_off),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Confirma tu contraseña';
                  if (v != _password.text) return 'Las contraseñas no coinciden';
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
                          width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Crear cuenta'),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿Ya tienes cuenta?'),
                  TextButton(
                    onPressed: () => LottieScreenTransition.playAndNavigate(
                      context,
                      asset: 'assets/lottie/intro-login.json',
                      routeName: AppRoutes.login,
                      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                      speedMultiplier: 4.0,
                    ),
                    child: const Text('Inicia sesión'),
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
