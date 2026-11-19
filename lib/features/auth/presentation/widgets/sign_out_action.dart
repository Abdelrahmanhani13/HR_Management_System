import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hr_management/core/widgets/feedback.dart';
import 'package:hr_management/features/auth/presentation/cubit/session_cubit.dart';

/// Asks for confirmation, then signs the user out. Shared by the app shell and
/// the profile screen.
Future<void> confirmAndSignOut(BuildContext context) async {
  final cubit = context.read<SessionCubit>();
  final confirmed = await showConfirmDialog(
    context,
    title: 'تسجيل الخروج؟',
    message: 'ستحتاج إلى تسجيل الدخول مرة أخرى لاستخدام التطبيق.',
    confirmLabel: 'تسجيل الخروج',
    destructive: true,
  );
  if (confirmed) {
    await cubit.signOut();
  }
}
