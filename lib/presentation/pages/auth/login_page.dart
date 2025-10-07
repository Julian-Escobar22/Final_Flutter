import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:todo/presentation/widgets/app_navbar.dart';
import 'package:todo/presentation/utils/lottie_transition.dart';
import 'package:todo/presentation/routes.dart';
import 'package:todo/presentation/widgets/particle_background.dart';
import 'package:todo/presentation/widgets/app_footer.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final isSmall = w < 700;
        final maxCard = isSmall ? w - 24 : 440.0;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F0FF), // mismo tono suave del landing
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
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('UI lista – conectaremos Supabase luego')),
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
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
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
                  onPressed: () {},
                  child: const Text('¿Olvidaste tu contraseña?'),
                ),
              ),
              const SizedBox(height: 6),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Ingresar'),
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
                      backgroundColor: const Color.fromARGB(255, 2, 2, 2),
                      speedMultiplier: 3.9,
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
