import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hr_management/features/attendance/data/datasources/attendance_remote_data_source.dart';
import 'package:hr_management/features/attendance/data/datasources/attendance_remote_data_source_impl.dart';
import 'package:hr_management/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:hr_management/features/attendance/domain/repositories/attendance_repository.dart';
import 'package:hr_management/features/attendance/domain/usecases/attendance_usecases.dart';
import 'package:hr_management/features/attendance/presentation/cubit/attendance_list_cubit.dart';
import 'package:hr_management/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:hr_management/features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'package:hr_management/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:hr_management/features/auth/domain/repositories/auth_repository.dart';
import 'package:hr_management/features/auth/domain/usecases/auth_usecases.dart';
import 'package:hr_management/features/auth/presentation/cubit/login_cubit.dart';
import 'package:hr_management/features/auth/presentation/cubit/password_cubits.dart';
import 'package:hr_management/features/auth/presentation/cubit/session_cubit.dart';
import 'package:hr_management/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:hr_management/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:hr_management/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:hr_management/features/dashboard/domain/usecases/get_dashboard_summary.dart';
import 'package:hr_management/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:hr_management/features/employees/data/datasources/employee_remote_data_source.dart';
import 'package:hr_management/features/employees/data/datasources/employee_remote_data_source_impl.dart';
import 'package:hr_management/features/employees/data/repositories/employee_repository_impl.dart';
import 'package:hr_management/features/employees/domain/repositories/employee_repository.dart';
import 'package:hr_management/features/employees/domain/usecases/employee_usecases.dart';
import 'package:hr_management/features/employees/presentation/cubit/employee_details_cubit.dart';
import 'package:hr_management/features/employees/presentation/cubit/employee_form_cubit.dart';
import 'package:hr_management/features/employees/presentation/cubit/employees_cubit.dart';
import 'package:hr_management/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:hr_management/features/profile/data/datasources/profile_remote_data_source_impl.dart';
import 'package:hr_management/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:hr_management/features/profile/domain/repositories/profile_repository.dart';
import 'package:hr_management/features/profile/domain/usecases/profile_usecases.dart';
import 'package:hr_management/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:hr_management/features/payroll/data/datasources/payroll_remote_data_source.dart';
import 'package:hr_management/features/payroll/data/datasources/payroll_remote_data_source_impl.dart';
import 'package:hr_management/features/payroll/data/repositories/payroll_repository_impl.dart';
import 'package:hr_management/features/payroll/domain/repositories/payroll_repository.dart';
import 'package:hr_management/features/payroll/domain/usecases/get_payroll_report.dart';
import 'package:hr_management/features/payroll/presentation/cubit/payroll_report_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GetIt sl = GetIt.instance;

/// Registers the app's dependencies. Call once, before `runApp`.
void configureDependencies() {
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  sl
    // Auth
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        sl<SupabaseClient>(),
        authRedirectUrl: dotenv.env['SUPABASE_AUTH_REDIRECT_URL'],
      ),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl<AuthRemoteDataSource>()),
    )
    ..registerLazySingleton(() => SignIn(sl<AuthRepository>()))
    ..registerLazySingleton(() => SignOut(sl<AuthRepository>()))
    ..registerLazySingleton(() => RestoreSession(sl<AuthRepository>()))
    ..registerLazySingleton(() => ObserveAuthState(sl<AuthRepository>()))
    ..registerLazySingleton(() => SendPasswordResetEmail(sl<AuthRepository>()))
    ..registerLazySingleton(() => UpdatePassword(sl<AuthRepository>()))
    ..registerLazySingleton(
      () => SessionCubit(
        restoreSession: sl<RestoreSession>(),
        signOut: sl<SignOut>(),
        observeAuthState: sl<ObserveAuthState>(),
      ),
    )
    ..registerFactory(() => LoginCubit(sl<SignIn>()))
    ..registerFactory(() => ForgotPasswordCubit(sl<SendPasswordResetEmail>()))
    ..registerFactory(() => ResetPasswordCubit(sl<UpdatePassword>()))
    // Dashboard
    ..registerLazySingleton<DashboardRemoteDataSource>(
      () => DashboardRemoteDataSourceImpl(sl<SupabaseClient>()),
    )
    ..registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(sl<DashboardRemoteDataSource>()),
    )
    ..registerLazySingleton(
      () => GetDashboardSummary(sl<DashboardRepository>()),
    )
    ..registerFactory(() => DashboardCubit(sl<GetDashboardSummary>()))
    // Employees
    ..registerLazySingleton<EmployeeRemoteDataSource>(
      () => EmployeeRemoteDataSourceImpl(sl<SupabaseClient>()),
    )
    ..registerLazySingleton<EmployeeRepository>(
      () => EmployeeRepositoryImpl(sl<EmployeeRemoteDataSource>()),
    )
    ..registerLazySingleton(() => GetEmployees(sl<EmployeeRepository>()))
    ..registerLazySingleton(() => GetEmployeeById(sl<EmployeeRepository>()))
    ..registerLazySingleton(() => GetDepartments(sl<EmployeeRepository>()))
    ..registerLazySingleton(() => CreateEmployee(sl<EmployeeRepository>()))
    ..registerLazySingleton(() => UpdateEmployee(sl<EmployeeRepository>()))
    ..registerLazySingleton(() => SetEmployeeActive(sl<EmployeeRepository>()))
    ..registerFactory(
      () => EmployeesCubit(
        getEmployees: sl<GetEmployees>(),
        getDepartments: sl<GetDepartments>(),
      ),
    )
    ..registerFactory(
      () => EmployeeDetailsCubit(
        getEmployeeById: sl<GetEmployeeById>(),
        setEmployeeActive: sl<SetEmployeeActive>(),
      ),
    )
    ..registerFactory(
      () => EmployeeFormCubit(
        getDepartments: sl<GetDepartments>(),
        getEmployeeById: sl<GetEmployeeById>(),
        createEmployee: sl<CreateEmployee>(),
        updateEmployee: sl<UpdateEmployee>(),
      ),
    )
    // Attendance
    ..registerLazySingleton<AttendanceRemoteDataSource>(
      () => AttendanceRemoteDataSourceImpl(sl<SupabaseClient>()),
    )
    ..registerLazySingleton<AttendanceRepository>(
      () => AttendanceRepositoryImpl(sl<AttendanceRemoteDataSource>()),
    )
    ..registerLazySingleton(
      () => GetAttendanceRecords(sl<AttendanceRepository>()),
    )
    ..registerLazySingleton(
      () => GetEmployeeOptions(sl<AttendanceRepository>()),
    )
    ..registerLazySingleton(
      () => CreateAttendanceRecord(sl<AttendanceRepository>()),
    )
    ..registerLazySingleton(
      () => UpdateAttendanceRecord(sl<AttendanceRepository>()),
    )
    ..registerFactory(
      () => AttendanceListCubit(
        getRecords: sl<GetAttendanceRecords>(),
        getEmployeeOptions: sl<GetEmployeeOptions>(),
        createRecord: sl<CreateAttendanceRecord>(),
        updateRecord: sl<UpdateAttendanceRecord>(),
      ),
    )
    // Profile
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(sl<SupabaseClient>()),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(sl<ProfileRemoteDataSource>()),
    )
    ..registerLazySingleton(() => GetMyProfile(sl<ProfileRepository>()))
    ..registerFactory(() => ProfileCubit(getMyProfile: sl<GetMyProfile>()))
    // Payroll
    ..registerLazySingleton<PayrollRemoteDataSource>(
      () => PayrollRemoteDataSourceImpl(sl<SupabaseClient>()),
    )
    ..registerLazySingleton<PayrollRepository>(
      () => PayrollRepositoryImpl(sl<PayrollRemoteDataSource>()),
    )
    ..registerLazySingleton(() => GetPayrollReport(sl<PayrollRepository>()))
    ..registerFactory(
      () => PayrollReportCubit(getPayrollReport: sl<GetPayrollReport>()),
    );
}
