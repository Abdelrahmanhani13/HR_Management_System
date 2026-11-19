import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hr_management/core/router/app_router.dart';
import 'package:hr_management/core/di/injection_container.dart';
import 'package:hr_management/core/theme/app_theme.dart';
import 'package:hr_management/features/auth/presentation/cubit/session_cubit.dart';

class HrApp extends StatefulWidget {
  const HrApp({super.key});

  @override
  State<HrApp> createState() => _HrAppState();
}

class _HrAppState extends State<HrApp> {
  late final SessionCubit _session = sl<SessionCubit>();
  late final GoRouter _router = createRouter(_session);

  @override
  void initState() {
    super.initState();
    // Restores the Supabase session, then the router redirects away from splash.
    _session.start();
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SessionCubit>.value(
      value: _session,
      child: MaterialApp.router(
        title: 'إدارة الموارد البشرية',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        routerConfig: _router,
      ),
    );
  }
}
