import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showSuccessDialog(
  BuildContext context, {
  required String title,
  required String message,
  VoidCallback? onOk,
}) async {
  return AwesomeDialog(
    context: context,
    dialogType: DialogType.noHeader, // <- SIN RIVE
    animType: AnimType.scale,
    customHeader: _HeaderIcon(
      color: Colors.green,
      icon: Icons.check_circle,
    ),
    title: title,
    desc: message,
    btnOkText: 'OK',
    btnOkOnPress: onOk,
    buttonsBorderRadius: const BorderRadius.all(Radius.circular(10)),
    headerAnimationLoop: false,
  ).show();
}

Future<void> showEmailConfirmationSentDialog(
  BuildContext context, {
  required String email,
  required VoidCallback onResend,
}) async {
  return AwesomeDialog(
    context: context,
    dialogType: DialogType.noHeader,
    animType: AnimType.scale,
    headerAnimationLoop: false,
    dismissOnTouchOutside: false,
    dismissOnBackKeyPress: true,
    title: 'Confirma tu correo',
    desc:
        'Te enviamos un enlace de verificación a:\n$email\n\n'
        'Debes confirmarlo para poder iniciar sesión.',
    btnOkText: 'Entendido',
    btnOkOnPress: () {},
    btnCancelText: 'Reenviar correo',
    btnCancelOnPress: onResend,
  ).show();
}

Future<void> showErrorDialog(
  BuildContext context, {
  required String title,
  required String message,
  VoidCallback? onOk,
}) async {
  return AwesomeDialog(
    context: context,
    dialogType: DialogType.noHeader, // <- SIN RIVE
    animType: AnimType.scale,
    customHeader: _HeaderIcon(
      color: Colors.red,
      icon: Icons.error_outline,
    ),
    title: title,
    desc: message,
    btnOkText: 'OK',
    btnOkColor: Colors.red,
    btnOkOnPress: onOk,
    buttonsBorderRadius: const BorderRadius.all(Radius.circular(10)),
    headerAnimationLoop: false,
  ).show();
}

Future<void> showEmailNotConfirmedDialog(
  BuildContext context, {
  required String email,
  required VoidCallback onResend,
}) async {
  return AwesomeDialog(
    context: context,
    dialogType: DialogType.noHeader, // <- SIN RIVE
    animType: AnimType.scale,
    customHeader: _HeaderIcon(
      color: Colors.amber.shade700,
      icon: Icons.mark_email_unread_outlined,
    ),
    title: 'Confirma tu correo',
    desc:
        'Aún no has confirmado tu cuenta.\n\nHemos enviado un enlace a:\n$email\n\nRevisa tu bandeja de entrada/Spam y vuelve a intentarlo.',
    btnOkText: 'Reenviar correo',
    btnOkOnPress: onResend,
    btnCancelText: 'Cerrar',
    btnCancelOnPress: () {},
    buttonsBorderRadius: const BorderRadius.all(Radius.circular(10)),
    headerAnimationLoop: false,
  ).show();
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.color, required this.icon});
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(12),
      child: Icon(icon, size: 40, color: color),
    );
  }
}
