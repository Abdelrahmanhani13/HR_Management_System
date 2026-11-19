import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hr_management/core/router/app_routes.dart';
import 'package:hr_management/core/theme/app_colors.dart';
import 'package:hr_management/core/theme/app_spacing.dart';
import 'package:hr_management/core/utils/formatters.dart';
import 'package:hr_management/core/utils/responsive.dart';
import 'package:hr_management/core/utils/view_status.dart';
import 'package:hr_management/core/widgets/app_assets.dart';
import 'package:hr_management/core/widgets/app_card.dart';
import 'package:hr_management/core/widgets/avatar_initials.dart';
import 'package:hr_management/core/widgets/brand_panel.dart';
import 'package:hr_management/core/widgets/content_frame.dart';
import 'package:hr_management/core/widgets/info_row.dart';
import 'package:hr_management/core/widgets/inline_banner.dart';
import 'package:hr_management/core/widgets/state_views.dart';
import 'package:hr_management/core/widgets/status_chip.dart';
import 'package:hr_management/features/auth/presentation/cubit/session_cubit.dart';
import 'package:hr_management/features/auth/presentation/widgets/sign_out_action.dart';
import 'package:hr_management/features/employees/domain/entities/employee.dart';
import 'package:hr_management/features/profile/domain/entities/user_profile.dart';
import 'package:hr_management/features/profile/presentation/cubit/profile_cubit.dart';

/// Needs a [ProfileCubit] above it.
///
/// Built on a plain scrolling list (no SliverFillRemaining / LayoutBuilder
/// inside intrinsic-size contexts), so it can never stall layout.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final email = context.select<SessionCubit, String?>(
      (cubit) => cubit.state.session?.email,
    );
    return ContentFrame(
      child: RefreshIndicator(
        onRefresh: () => context.read<ProfileCubit>().load(silent: true),
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            final failure = state.failure;
            final profile = state.profile;
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              children: [
                if (state.status == ViewStatus.failure &&
                    failure != null &&
                    profile == null)
                  ErrorView(
                    failure: failure,
                    onRetry: () => context.read<ProfileCubit>().load(),
                  )
                else if (profile == null)
                  const SizedBox(height: 320, child: LoadingView())
                else
                  _ProfileBody(profile: profile, email: email),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.profile, required this.email});

  final UserProfile profile;
  final String? email;

  @override
  Widget build(BuildContext context) {
    final employee = profile.employee;
    final wide = !Responsive.isCompact(context) &&
        MediaQuery.sizeOf(context).width >= 860;

    final left = <Widget>[
      _AccountCard(profile: profile, email: email),
      if (employee != null) _PersonalCard(employee: employee),
    ];
    final right = <Widget>[
      if (employee != null)
        _WorkCard(employee: employee)
      else
        const _NoEmployeeCard(),
    ];

    Widget column(List<Widget> items) => Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          items[i],
        ],
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProfileHero(profile: profile, email: email),
        if (employee != null) ...[
          const SizedBox(height: AppSpacing.md),
          _HighlightsRow(employee: employee),
        ],
        const SizedBox(height: AppSpacing.md),
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: column(left)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: column(right)),
            ],
          )
        else
          column([...left, ...right]),
        const SizedBox(height: AppSpacing.lg),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.dangerBg),
            ),
            onPressed: () => confirmAndSignOut(context),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('تسجيل الخروج'),
          ),
        ),
      ],
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile, required this.email});

  final UserProfile profile;
  final String? email;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final name = profile.displayName ?? email ?? 'مستخدم';
    final employee = profile.employee;
    final role = profile.roleName;

    return BrandPanel(
      image: AppAssets.headerLightArcs,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          AvatarInitials(name: name, size: 76),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                    letterSpacing: -0.4,
                  ),
                ),
                if (email != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    email!,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.start,
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs + 2,
                  runSpacing: AppSpacing.xs,
                  children: [
                    if (role != null)
                      StatusChip(
                        label: role,
                        tone: StatusTone.info,
                        icon: Icons.verified_user_outlined,
                      ),
                    if (employee?.departmentName != null)
                      StatusChip(
                        label: employee!.departmentName!,
                        tone: StatusTone.neutral,
                        icon: Icons.business_outlined,
                      ),
                    if (employee != null)
                      StatusChip(
                        label: employee.isActive ? 'نشط' : 'غير نشط',
                        tone: employee.isActive
                            ? StatusTone.success
                            : StatusTone.neutral,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Three at-a-glance facts: department, time with the company, shift.
class _HighlightsRow extends StatelessWidget {
  const _HighlightsRow({required this.employee});

  final Employee employee;

  static String tenure(DateTime from, DateTime now) {
    var months = (now.year - from.year) * 12 + now.month - from.month;
    if (now.day < from.day) months -= 1;
    if (months < 1) return 'أقل من شهر';
    final years = months ~/ 12;
    final rest = months % 12;
    if (years == 0) return '$rest شهر';
    if (rest == 0) return '$years سنة';
    return '$years سنة و$rest شهر';
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _Highlight(
        icon: Icons.business_outlined,
        label: 'القسم',
        value: employee.departmentName ?? 'غير محدد',
        tone: StatusTone.info,
      ),
      _Highlight(
        icon: Icons.workspace_premium_outlined,
        label: 'مدة العمل',
        value: tenure(employee.contractDate, DateTime.now()),
        tone: StatusTone.success,
      ),
      _Highlight(
        icon: Icons.schedule,
        label: 'ساعات الدوام',
        value:
            '${AppFormat.time(employee.checkInTime)} – '
            '${AppFormat.time(employee.checkOutTime)}',
        tone: StatusTone.warning,
      ),
    ];
    final compact = MediaQuery.sizeOf(context).width < 700;
    if (compact) {
      return Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.sm),
            items[i],
          ],
        ],
      );
    }
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(child: items[i]),
        ],
      ],
    );
  }
}

class _Highlight extends StatelessWidget {
  const _Highlight({
    required this.icon,
    required this.label,
    required this.value,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final String value;
  final StatusTone tone;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.sm + 4),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tone.background(context),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: tone.foreground(context), size: 22),
          ),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
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
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('بيانات الحساب'),
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
          InfoRow(
            label: 'آخر تحديث',
            value: AppFormat.dateTime(profile.updatedAt),
          ),
        ],
      ),
    );
  }
}

class _PersonalCard extends StatelessWidget {
  const _PersonalCard({required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('البيانات الشخصية'),
          InfoRow(label: 'النوع', value: employee.gender.label),
          InfoRow(
            label: 'تاريخ الميلاد',
            value: AppFormat.date(employee.dateOfBirth),
          ),
          InfoRow(label: 'الجنسية', value: employee.nationality),
          InfoRow(label: 'الرقم القومي', value: employee.nationalId),
          InfoRow(label: 'الهاتف', value: employee.phone),
          InfoRow(label: 'العنوان', value: employee.address),
        ],
      ),
    );
  }
}

class _WorkCard extends StatelessWidget {
  const _WorkCard({required this.employee});

  final Employee employee;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push(AppRoutes.employeeDetails(employee.id)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: SectionTitle('بيانات العمل')),
              Icon(
                Icons.chevron_left,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          InfoRow(
            label: 'القسم',
            value: employee.departmentName ?? 'غير متاح',
          ),
          InfoRow(
            label: 'تاريخ العقد',
            value: AppFormat.date(employee.contractDate),
          ),
          InfoRow(label: 'الراتب', value: AppFormat.number(employee.salary)),
          InfoRow(
            label: 'بداية الدوام',
            value: AppFormat.time(employee.checkInTime),
          ),
          InfoRow(
            label: 'نهاية الدوام',
            value: AppFormat.time(employee.checkOutTime),
          ),
          InfoRow(
            label: 'الحالة',
            value: employee.isActive ? 'نشط' : 'غير نشط',
          ),
        ],
      ),
    );
  }
}

class _NoEmployeeCard extends StatelessWidget {
  const _NoEmployeeCard();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('سجل الموظف'),
          InlineBanner(
            message:
                'لا يوجد سجل موظف مرتبط بهذا الحساب، لذلك لا تظهر بيانات '
                'العمل والبيانات الشخصية. اطلب من المسؤول ربطه.',
            tone: StatusTone.info,
            icon: Icons.info_outline,
          ),
        ],
      ),
    );
  }
}
