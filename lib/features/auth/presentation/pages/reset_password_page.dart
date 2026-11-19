import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hr_management/core/router/app_routes.dart';
import 'package:hr_management/core/theme/app_spacing.dart';
import 'package:hr_management/core/utils/validators.dart';
import 'package:hr_management/core/utils/view_status.dart';
import 'package:hr_management/core/widgets/inline_banner.dart';
import 'package:hr_management/core/widgets/status_chip.dart';
import 'package:hr_management/features/auth/presentation/cubit/password_cubits.dart';
import 'package:hr_management/features/auth/presentation/cubit/session_cubit.dart';
import 'package:hr_management/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:hr_management/features/auth/presentation/widgets/submit_button.dart';

/// Opened from the password-reset link.
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ResetPasswordCubit>().submit(_passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResetPasswordCubit, PasswordActionState>(
      builder: (context, state) {
        final done = state.status == SubmissionStatus.success;
        final failure = state.failure;
        return AuthScaffold(
          title: 'إنشاء كلمة مرور جديدة',
          subtitle: 'اختر كلمة مرور آمنة لم تستخدمها من قبل.',
          child: done
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const InlineBanner(
                      message: 'تم تحديث كلمة المرور بنجاح.',
                      tone: StatusTone.success,
                      icon: Icons.check_circle_outline,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: () {
                        context.read<SessionCubit>().clearPasswordRecovery();
                        context.go(AppRoutes.login);
                      },
                      child: const Text('متابعة'),
                    ),
                  ],
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (failure != null) ...[
                        InlineBanner.failure(failure),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      TextFormField(
                        controller: _passwordController,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.left,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور الجديدة',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _obscure
                                ? 'إظهار كلمة المرور'
                                : 'إخفاء كلمة المرور',
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: Validators.newPassword,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _confirmController,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.left,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: const InputDecoration(
                          labelText: 'تأكيد كلمة المرور الجديدة',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (value) => Validators.confirmPassword(
                          value,
                          _passwordController.text,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SubmitButton(
                        label: 'تحديث كلمة المرور',
                        busy: state.status == SubmissionStatus.submitting,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
