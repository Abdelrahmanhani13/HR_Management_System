import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hr_management/core/router/app_routes.dart';
import 'package:hr_management/core/theme/app_spacing.dart';
import 'package:hr_management/core/utils/validators.dart';
import 'package:hr_management/core/utils/view_status.dart';
import 'package:hr_management/core/widgets/inline_banner.dart';
import 'package:hr_management/features/auth/presentation/cubit/login_cubit.dart';
import 'package:hr_management/features/auth/presentation/cubit/session_cubit.dart';
import 'package:hr_management/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:hr_management/features/auth/presentation/widgets/submit_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<LoginCubit>().submit(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        final session = state.session;
        if (state.status == SubmissionStatus.success && session != null) {
          // The router redirects to the dashboard once the session is set.
          context.read<SessionCubit>().setSession(session);
        }
      },
      builder: (context, state) {
        final busy = state.status == SubmissionStatus.submitting;
        final failure = state.failure;
        return AuthScaffold(
          title: 'مرحبًا بعودتك',
          subtitle: 'سجّل الدخول إلى مساحة عمل الموارد البشرية.',
          child: Form(
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
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _passwordController,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? 'إظهار كلمة المرور'
                          : 'إخفاء كلمة المرور',
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (value) =>
                      Validators.required(value, 'كلمة المرور'),
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () => context.push(AppRoutes.forgotPassword),
                    child: const Text('هل نسيت كلمة المرور؟'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SubmitButton(label: 'تسجيل الدخول', busy: busy, onPressed: _submit),
              ],
            ),
          ),
        );
      },
    );
  }
}
