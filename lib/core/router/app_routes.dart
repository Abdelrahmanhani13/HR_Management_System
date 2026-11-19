/// Route paths shared by the router (app layer) and the screens that navigate.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  static const String dashboard = '/dashboard';
  static const String employees = '/employees';
  static const String employeeNew = '/employees/new';
  static const String attendance = '/attendance';
  static const String payroll = '/payroll';
  static const String profile = '/profile';

  static String employeeDetails(String id) => '/employees/$id';

  static String employeeEdit(String id) => '/employees/$id/edit';

  /// Screens reachable without a session.
  static const Set<String> publicRoutes = {login, forgotPassword};
}
