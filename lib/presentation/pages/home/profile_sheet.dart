import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo/presentation/controllers/auth_controller.dart';
import 'package:todo/presentation/routes.dart';


class ProfileSheet extends StatefulWidget {
  const ProfileSheet({super.key});

  @override
  State<ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<ProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  String _avatar = '🧠';
  String _career = 'Ingeniería de Software';
  bool _saving = false;

  // Presets
  final _avatars = const ['🧠', '📚', '🧑‍💻', '🤖', '✨', '🦉', '🧩', '🚀'];
  final _careers = const [
    'Ingeniería de Software',
    'Ingeniería de Sistemas',
    'Ciencia de Datos',
    'Matemáticas',
    'Administración',
    'Otra',
  ];

  late final AuthController _auth;

  @override
  void initState() {
    super.initState();
    _auth = Get.find<AuthController>();
    final u = Supabase.instance.client.auth.currentUser;
    final meta = (u?.userMetadata ?? {}) as Map<String, dynamic>;
    _nameCtrl.text = (meta['full_name'] as String?)?.trim() ?? '';
    _avatar = (meta['avatar'] as String?) ?? _avatar;
    _career = (meta['career'] as String?) ?? _career;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': _nameCtrl.text.trim(),
            'avatar': _avatar,
            'career': _career,
          },
        ),
      );
      await _auth.loadSession(); // refresca user en GetX
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );
      Navigator.of(context).maybePop(); // cerrar sheet
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final email = _auth.user.value?.email ?? '—';

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              child: Card(
                color: const Color(0xfff9f6ff),
                elevation: 8,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 4,
                          width: 40,
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: t.colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Text(
                          'Tu perfil',
                          style: t.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Actualiza tu información visible en la app.',
                          style: t.textTheme.bodyMedium?.copyWith(
                            color: t.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),

                        // Email (solo lectura)
                        TextFormField(
                          initialValue: email,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Correo',
                            prefixIcon: Icon(Icons.alternate_email),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Nombre visible
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Nombre visible',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Ingresa tu nombre';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Avatar (chips de emojis)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Avatar',
                            style: t.textTheme.labelLarge,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _avatars.map((e) {
                            final selected = _avatar == e;
                            return ChoiceChip(
                              label: Text(e, style: const TextStyle(fontSize: 18)),
                              selected: selected,
                              onSelected: (_) => setState(() => _avatar = e),
                              selectedColor: t.colorScheme.primary.withOpacity(0.12),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),

                        // Carrera (dropdown)
                        DropdownButtonFormField<String>(
                          value: _career,
                          decoration: const InputDecoration(
                            labelText: 'Carrera',
                            prefixIcon: Icon(Icons.school_outlined),
                          ),
                          isExpanded: true,
                          items: _careers
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _career = v ?? _career),
                        ),
                        const SizedBox(height: 18),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.logout),
                                label: const Text('Cerrar sesión'),
                                onPressed: _saving
                                    ? null
                                    : () async {
                                        await _auth.doSignOut();
                                        if (context.mounted) {
                                          Get.offAllNamed(AppRoutes.landing);
                                        }
                                      },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton.icon(
                                icon: _saving
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.save_outlined),
                                label: const Text('Guardar'),
                                onPressed: _saving ? null : _save,
                              ),
                            ),
                          ],
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
    );
  }
}
