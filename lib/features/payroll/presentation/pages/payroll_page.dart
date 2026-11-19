import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hr_management/core/theme/app_spacing.dart';
import 'package:hr_management/core/utils/formatters.dart';
import 'package:hr_management/core/utils/view_status.dart';
import 'package:hr_management/core/widgets/app_card.dart';
import 'package:hr_management/core/widgets/content_frame.dart';
import 'package:hr_management/core/widgets/info_row.dart';
import 'package:hr_management/core/widgets/page_header.dart';
import 'package:hr_management/core/widgets/state_views.dart';
import 'package:hr_management/features/payroll/domain/entities/payroll_report_row.dart';
import 'package:hr_management/features/payroll/presentation/cubit/payroll_report_cubit.dart';

class PayrollPage extends StatelessWidget {
  const PayrollPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PayrollReportCubit, PayrollReportState>(
      builder: (context, state) {
        final cubit = context.read<PayrollReportCubit>();
        final period = MaterialLocalizations.of(
          context,
        ).formatMonthYear(DateTime(state.year, state.month));
        final current = DateTime.now();
        final isCurrentPeriod =
            state.year == current.year && state.month == current.month;

        return ContentFrame(
          child: RefreshIndicator(
            onRefresh: () => cubit.load(silent: true),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PageHeader(
                        title: 'الرواتب',
                        subtitle: 'تقرير الرواتب والخصومات حسب الحضور',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AppCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              tooltip: 'الشهر السابق',
                              onPressed: cubit.previousMonth,
                              icon: const Icon(Icons.chevron_left),
                            ),
                            Expanded(
                              child: Text(
                                period,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            IconButton(
                              tooltip: 'الشهر التالي',
                              onPressed: isCurrentPeriod
                                  ? null
                                  : cubit.nextMonth,
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                  ),
                ),
                _PayrollRowsSliver(state: state, onRetry: () => cubit.load()),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xl),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PayrollRowsSliver extends StatelessWidget {
  const _PayrollRowsSliver({required this.state, required this.onRetry});

  final PayrollReportState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final failure = state.failure;
    if (state.status == ViewStatus.failure && failure != null) {
      return SliverToBoxAdapter(
        child: ErrorView(failure: failure, onRetry: onRetry),
      );
    }
    if (state.status == ViewStatus.initial ||
        (state.status == ViewStatus.loading && state.rows.isEmpty)) {
      return const SliverToBoxAdapter(child: LoadingView());
    }
    if (state.rows.isEmpty) {
      return const SliverToBoxAdapter(
        child: EmptyView(
          icon: Icons.payments_outlined,
          title: 'لا توجد بيانات رواتب',
          message: 'لا يوجد موظفون مستحقون للعرض خلال هذه الفترة.',
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: _PayrollCard(row: state.rows[index]),
        ),
        childCount: state.rows.length,
      ),
    );
  }
}

class _PayrollCard extends StatelessWidget {
  const _PayrollCard({required this.row});

  final PayrollReportRow row;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            row.fullName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            row.departmentName ?? 'بدون قسم',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          InfoRow(
            label: 'الراتب الأساسي',
            value: AppFormat.number(row.baseSalary),
          ),
          InfoRow(
            label: 'أيام الحضور / الغياب',
            value: '${row.presentDays} / ${row.absentDays}',
          ),
          InfoRow(
            label: 'ساعات إضافية',
            value: AppFormat.number(row.overtimeHours),
          ),
          InfoRow(
            label: 'تأخير / انصراف مبكر',
            value: AppFormat.number(row.lateHours),
          ),
          const Divider(height: AppSpacing.md),
          InfoRow(label: 'إضافي', value: AppFormat.number(row.overtimeAmount)),
          InfoRow(
            label: 'خصم التأخير',
            value: AppFormat.number(row.lateDeduction),
          ),
          InfoRow(
            label: 'خصم الغياب',
            value: AppFormat.number(row.absenceDeduction),
          ),
          const SizedBox(height: AppSpacing.sm),
          LayoutBuilder(
            builder: (context, constraints) {
              const label = Text(
                'صافي الراتب',
                style: TextStyle(fontWeight: FontWeight.w700),
              );
              final amount = Text(
                AppFormat.number(row.netSalary),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              );
              if (constraints.maxWidth < 320) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    label,
                    const SizedBox(height: AppSpacing.xs),
                    amount,
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [label, amount],
              );
            },
          ),
        ],
      ),
    );
  }
}
