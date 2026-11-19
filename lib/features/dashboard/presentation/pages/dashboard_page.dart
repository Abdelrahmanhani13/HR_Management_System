import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hr_management/core/router/app_routes.dart';
import 'package:hr_management/core/theme/app_spacing.dart';
import 'package:hr_management/core/utils/formatters.dart';
import 'package:hr_management/core/utils/view_status.dart';
import 'package:hr_management/core/theme/app_colors.dart';
import 'package:hr_management/core/widgets/adaptive_grid.dart';
import 'package:hr_management/core/widgets/app_assets.dart';
import 'package:hr_management/core/widgets/brand_panel.dart';
import 'package:hr_management/core/widgets/content_frame.dart';
import 'package:hr_management/core/widgets/info_row.dart';
import 'package:hr_management/core/widgets/stat_card.dart';
import 'package:hr_management/core/widgets/state_views.dart';
import 'package:hr_management/core/widgets/status_chip.dart';
import 'package:hr_management/features/dashboard/domain/entities/dashboard_summary.dart';
import 'package:hr_management/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:hr_management/features/profile/presentation/cubit/profile_cubit.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Shows the user's name (never the email). Until the profile has loaded,
    // or when it has no name, only the date is shown.
    final name = context.select<ProfileCubit, String?>(
      (c) => c.state.profile?.displayName,
    );
    return ContentFrame(
      child: RefreshIndicator(
        onRefresh: () => context.read<DashboardCubit>().load(silent: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            _WelcomeHero(
              subtitle: name == null
                  ? AppFormat.dateLong(DateTime.now())
                  : '${AppFormat.dateLong(DateTime.now())} · $name',
            ),
            const SizedBox(height: AppSpacing.lg),
            BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                final summary = state.summary;
                final failure = state.failure;
                if (summary == null) {
                  if (state.status == ViewStatus.failure && failure != null) {
                    return ErrorView(
                      failure: failure,
                      onRetry: context.read<DashboardCubit>().load,
                    );
                  }
                  return const LoadingView();
                }
                return _SummaryBody(summary: summary);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            const _QuickActions(),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

/// Welcome banner on the dark brand artwork. White text sits on the navy
/// side of the gradient so it stays readable.
class _WelcomeHero extends StatelessWidget {
  const _WelcomeHero({required this.subtitle});

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return BrandPanel(
      image: AppAssets.heroDarkWaves,
      dark: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مرحبًا بك في بيونيرز',
              style: textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.86),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBody extends StatelessWidget {
  const _SummaryBody({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('الموظفون'),
        AdaptiveGrid(
          children: [
            StatCard(
              label: 'إجمالي الموظفين',
              value: AppFormat.number(summary.totalEmployees),
              icon: Icons.groups_outlined,
              tone: StatusTone.info,
            ),
            StatCard(
              label: 'نشط',
              value: AppFormat.number(summary.activeEmployees),
              icon: Icons.verified_user_outlined,
              tone: StatusTone.success,
            ),
            StatCard(
              label: 'غير نشط',
              value: AppFormat.number(summary.inactiveEmployees),
              icon: Icons.person_off_outlined,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        const SectionTitle('الحضور اليوم'),
        AdaptiveGrid(
          children: [
            StatCard(
              label: 'سجّلوا الحضور',
              value: AppFormat.number(summary.checkedInToday),
              icon: Icons.login,
              tone: StatusTone.success,
            ),
            StatCard(
              label: 'حالات التأخير',
              value: AppFormat.number(summary.lateToday),
              icon: Icons.alarm,
              tone: StatusTone.warning,
            ),
            StatCard(
              label: 'على رأس العمل',
              value: AppFormat.number(summary.currentlyWorking),
              icon: Icons.work_outline,
              tone: StatusTone.info,
            ),
            StatCard(
              label: 'سجّلوا الانصراف',
              value: AppFormat.number(summary.checkedOutToday),
              icon: Icons.logout,
            ),
            StatCard(
              label: 'لم يسجّلوا الحضور',
              value: AppFormat.number(summary.notCheckedIn),
              icon: Icons.hourglass_empty,
              tone: StatusTone.danger,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _AttendanceBar(summary: summary),
      ],
    );
  }
}

/// One-line proportion of active employees who have checked in today.
class _AttendanceBar extends StatelessWidget {
  const _AttendanceBar({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final active = summary.activeEmployees;
    final ratio = active == 0
        ? 0.0
        : (summary.checkedInToday / active).clamp(0.0, 1.0);
    final textTheme = Theme.of(context).textTheme;
    final countLabel =
        '${AppFormat.number(summary.checkedInToday)} من أصل '
        '${AppFormat.number(active)} موظف نشط';
    return BrandPanel(
      image: AppAssets.sectionDiagonalBars,
      radius: AppRadius.md,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final title = Text(
                'نسبة تسجيل الحضور',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              );
              final count = Text(
                countLabel,
                textAlign: TextAlign.end,
                style: textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              );

              if (constraints.maxWidth < 440) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    const SizedBox(height: AppSpacing.xs),
                    count,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: title),
                  const SizedBox(width: AppSpacing.sm),
                  Flexible(child: count),
                ],
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              color: AppColors.teal,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('إجراءات سريعة'),
        Wrap(
          spacing: AppSpacing.sm + 4,
          runSpacing: AppSpacing.sm + 4,
          children: [
            FilledButton.icon(
              onPressed: () => context.push(AppRoutes.employeeNew),
              icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
              label: const Text('إضافة موظف'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.attendance),
              icon: const Icon(Icons.fingerprint, size: 18),
              label: const Text('إدارة الحضور'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.employees),
              icon: const Icon(Icons.groups_outlined, size: 18),
              label: const Text('عرض الموظفين'),
            ),
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.profile),
              icon: const Icon(Icons.account_circle_outlined, size: 18),
              label: const Text('ملفي الشخصي'),
            ),
          ],
        ),
      ],
    );
  }
}
