import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hr_management/core/di/injection_container.dart';
import 'package:hr_management/core/router/app_routes.dart';
import 'package:hr_management/core/router/router_refresh.dart';
import 'package:hr_management/core/widgets/state_views.dart';
import 'package:hr_management/core/widgets/app_shell.dart';
import 'package:hr_management/features/attendance/presentation/cubit/attendance_list_cubit.dart';
import 'package:hr_management/features/attendance/presentation/pages/attendance_page.dart';
import 'package:hr_management/features/auth/presentation/cubit/login_cubit.dart';
import 'package:hr_management/features/auth/presentation/cubit/password_cubits.dart';
import 'package:hr_management/features/auth/presentation/cubit/session_cubit.dart';
import 'package:hr_management/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:hr_management/features/auth/presentation/pages/login_page.dart';
import 'package:hr_management/features/auth/presentation/pages/reset_password_page.dart';
import 'package:hr_management/features/auth/presentation/pages/splash_page.dart';
import 'package:hr_management/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:hr_management/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:hr_management/features/employees/presentation/cubit/employee_details_cubit.dart';
import 'package:hr_management/features/employees/presentation/cubit/employee_form_cubit.dart';
import 'package:hr_management/features/employees/presentation/cubit/employees_cubit.dart';
import 'package:hr_management/features/employees/presentation/pages/employee_details_page.dart';
import 'package:hr_management/features/employees/presentation/pages/employee_form_page.dart';
import 'package:hr_management/features/employees/presentation/pages/employees_page.dart';
import 'package:hr_management/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:hr_management/features/profile/presentation/pages/profile_page.dart';
import 'package:hr_management/features/payroll/presentation/cubit/payroll_report_cubit.dart';
import 'package:hr_management/features/payroll/presentation/pages/payroll_page.dart';

/// Where a user in [status] visiting [location] must be sent, or `null` to
/// stay. Pure function so the rules can be unit tested.
String? resolveRedirect({
  required SessionStatus status,
  required String location,
  bool isPasswordRecovery = false,
}) {
  if (isPasswordRecovery && location != AppRoutes.resetPassword) {
    return AppRoutes.resetPassword;
  }

  switch (status) {
    case SessionStatus.unknown:
      return location == AppRoutes.splash ? null : AppRoutes.splash;
    case SessionStatus.unauthenticated:
      final open =
          AppRoutes.publicRoutes.contains(location) ||
          location == AppRoutes.resetPassword;
      return open ? null : AppRoutes.login;
    case SessionStatus.authenticated:
      final authOnly =
          location == AppRoutes.splash ||
          AppRoutes.publicRoutes.contains(location);
      return authOnly ? AppRoutes.dashboard : null;
  }
}

GoRouter createRouter(SessionCubit session) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: StreamRefreshListenable(session.stream),
    redirect: (context, state) => resolveRedirect(
      status: session.state.status,
      location: state.uri.path,
      isPasswordRecovery: session.state.isPasswordRecovery,
    ),
    errorBuilder: (context, state) => Scaffold(
      body: EmptyView(
        icon: Icons.travel_explore_outlined,
        title: 'Page not found',
        message: 'The page you opened does not exist.',
        action: FilledButton(
          onPressed: () => context.go(AppRoutes.dashboard),
          child: const Text('Go to dashboard'),
        ),
      ),
    ),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<LoginCubit>(),
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<ForgotPasswordCubit>(),
          child: const ForgotPasswordPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<ResetPasswordCubit>(),
          child: const ResetPasswordPage(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => BlocProvider(
              create: (_) => sl<DashboardCubit>()..load(),
              child: const DashboardPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.employees,
            builder: (context, state) => BlocProvider(
              create: (_) => sl<EmployeesCubit>()..init(),
              child: const EmployeesPage(),
            ),
          ),
          // Must come before `/employees/:id`, or "new" is read as an id.
          GoRoute(
            path: AppRoutes.employeeNew,
            builder: (context, state) => BlocProvider(
              create: (_) => sl<EmployeeFormCubit>()..init(),
              child: const EmployeeFormPage(),
            ),
          ),
          GoRoute(
            path: '/employees/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return BlocProvider(
                create: (_) => sl<EmployeeDetailsCubit>()..load(id),
                child: EmployeeDetailsPage(employeeId: id),
              );
            },
          ),
          GoRoute(
            path: '/employees/:id/edit',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return BlocProvider(
                create: (_) => sl<EmployeeFormCubit>()..init(employeeId: id),
                child: EmployeeFormPage(employeeId: id),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.attendance,
            builder: (context, state) => BlocProvider(
              create: (_) => sl<AttendanceListCubit>()..init(),
              child: const AttendancePage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.payroll,
            builder: (context, state) => BlocProvider(
              create: (_) => sl<PayrollReportCubit>()..load(),
              child: const PayrollPage(),
            ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => BlocProvider(
              create: (_) => sl<ProfileCubit>()..load(),
              child: const ProfilePage(),
            ),
          ),
        ],
      ),
    ],
  );
}
