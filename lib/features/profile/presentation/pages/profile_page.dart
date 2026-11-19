import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hr_management/core/router/app_routes.dart';
import 'package:hr_management/core/theme/app_spacing.dart';
import 'package:hr_management/core/utils/formatters.dart';
import 'package:hr_management/core/utils/view_status.dart';
import 'package:hr_management/core/widgets/app_card.dart';
import 'package:hr_management/core/widgets/avatar_initials.dart';
import 'package:hr_management/core/widgets/content_frame.dart';
import 'package:hr_management/core/widgets/info_row.dart';
import 'package:hr_management/core/widgets/inline_banner.dart';
import 'package:hr_management/core/widgets/page_header.dart';
import 'package:hr_management/core/widgets/state_views.dart';
import 'package:hr_management/core/widgets/status_chip.dart';
import 'package:hr_management/features/auth/presentation/cubit/session_cubit.dart';
import 'package:hr_management/features/auth/presentation/widgets/sign_out_action.dart';
import 'package:hr_management/features/employees/domain/entities/employee.dart';
import 'package:hr_management/features/profile/domain/entities/user_profile.dart';
import 'package:hr_management/features/profile/presentation/cubit/profile_cubit.dart';

/// Needs a [ProfileCubit] above it.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final email = context.select<SessionCubit, String?>(
          (cubit) => cubit.state.session?.email,
        );
        return ContentFrame(
          child: RefreshIndicator(
            onRefresh: () => context.read<ProfileCubit>().load(silent: true),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: PageHeader(
                    title: 'الملف الشخصي',
                    subtitle: 'بيانات حسابك وسجل الموظف المرتبط به',
                    actions: [
                      OutlinedButton.icon(
                        onPressed: () => confirmAndSignOut(context),
                        icon: const Icon(Icons.logout, size: 18),
                        label: const Text('تسجيل الخروج'),
                      ),
                    ],
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.md),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _body(context, state, email),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, ProfileState state, String? email) {
    final failure = state.failure;
    if (state.status == ViewStatus.failure && failure != null) {
      return ErrorView(
        failure: failure,
        onRetry: () => context.read<ProfileCubit>().load(),
      );
    }
    final profile = state.profile;
    if (profile == null) return const LoadingView();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final account = _AccountCard(profile: profile, email: email);
          final employee = _LinkedEmployeeCard(employee: profile.employee);
          if (constraints.maxWidth >= 760) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: account),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: employee),
              ],
            );
          }
          return Column(
            children: [
              account,
              const SizedBox(height: AppSpacing.md),
              employee,
            ],
          );
        },
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.profile, required this.email});

  final UserProfile profile;
  final String? email;

  @override
  Widget build(BuildContext context) {
    final name = profile.displayName ?? email ?? 'مستخدم';
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarInitials(name: name, size: 52),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const SectionTitle('الحساب'),
          InfoRow(
            label: 'الاسم الكامل',
            value: profile.displayName ?? 'غير محدد',
          ),
          InfoRow(label: 'البريد الإلكتروني', value: email ?? 'غير متاح'),
          InfoRow(label: 'الدور', value: profile.roleName ?? 'غير محدد'),
          InfoRow(
            label: 'تاريخ الانضمام',
            value: AppFormat.date(profile.createdAt.toLocal()),
          ),
        ],
      ),
    );
  }
}

class _LinkedEmployeeCard extends StatelessWidget {
  const _LinkedEmployeeCard({required this.employee});

  final Employee? employee;

  @override
  Widget build(BuildContext context) {
    final employee = this.employee;
    if (employee == null) {
      return const AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle('سجل الموظف'),
            InlineBanner(
              message:
                  'لا يوجد سجل موظف مرتبط بهذا الحساب. '
                  'اطلب من المسؤول ربطه.',
              tone: StatusTone.info,
              icon: Icons.info_outline,
            ),
          ],
        ),
      );
    }
    return AppCard(
      onTap: () => context.push(AppRoutes.employeeDetails(employee.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: SectionTitle('سجل الموظف')),
              StatusChip(
                label: employee.isActive ? 'نشط' : 'غير نشط',
                tone: employee.isActive
                    ? StatusTone.success
                    : StatusTone.neutral,
              ),
            ],
          ),
          InfoRow(label: 'الاسم', value: employee.fullName),
          InfoRow(label: 'القسم', value: employee.departmentName ?? 'غير متاح'),
          InfoRow(label: 'الهاتف', value: employee.phone),
          InfoRow(
            label: 'تاريخ العقد',
            value: AppFormat.date(employee.contractDate),
          ),
          InfoRow(
            label: 'ساعات العمل',
            value:
                '${AppFormat.time(employee.checkInTime)} – '
                '${AppFormat.time(employee.checkOutTime)}',
          ),
        ],
      ),
    );
  }
}
