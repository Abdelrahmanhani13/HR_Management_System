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
import 'package:hr_management/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:hr_management/features/auth/presentation/widgets/submit_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ForgotPasswordCubit>().submit(_emailController.text);
  }

  void _backToLogin() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForgotPasswordCubit, PasswordActionState>(
      builder: (context, state) {
        final sent = state.status == SubmissionStatus.success;
        final failure = state.failure;
        return AuthScaffold(
          title: 'استعادة كلمة المرور',
          subtitle: 'أدخل بريدك الإلكتروني وسنرسل إليك رابط إعادة التعيين.',
          child: sent
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InlineBanner(
                      message:
                          'أُرسلت تعليمات إعادة التعيين إلى '
                          '${_emailController.text.trim()}.',
                      tone: StatusTone.success,
                      icon: Icons.check_circle_outline,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton(
                      onPressed: _backToLogin,
                      child: const Text('العودة إلى تسجيل الدخول'),
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
                        controller: _emailController,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.left,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _submit(),
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                        validator: Validators.email,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SubmitButton(
                        label: 'إرسال رابط الاستعادة',
                        busy: state.status == SubmissionStatus.submitting,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: _backToLogin,
                        child: const Text('العودة إلى تسجيل الدخول'),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
