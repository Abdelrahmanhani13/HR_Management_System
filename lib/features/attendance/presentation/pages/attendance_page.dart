import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hr_management/core/widgets/app_assets.dart';
import 'package:hr_management/core/widgets/app_feedback_dialog.dart';
import 'package:hr_management/core/theme/app_spacing.dart';
import 'package:hr_management/core/utils/formatters.dart';
import 'package:hr_management/core/utils/view_status.dart';
import 'package:hr_management/core/widgets/content_frame.dart';
import 'package:hr_management/core/widgets/page_header.dart';
import 'package:hr_management/core/widgets/state_views.dart';
import 'package:hr_management/features/attendance/presentation/cubit/attendance_list_cubit.dart';
import 'package:hr_management/features/attendance/domain/entities/attendance_record.dart';
import 'package:hr_management/features/attendance/presentation/widgets/attendance_filters.dart';
import 'package:hr_management/features/attendance/presentation/widgets/attendance_record_tile.dart';
import 'package:hr_management/features/attendance/presentation/widgets/attendance_entry_dialog.dart';

/// Needs an [AttendanceListCubit] above it.
class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final listCubit = context.read<AttendanceListCubit>();
    return ContentFrame(
      child: RefreshIndicator(
        onRefresh: () => listCubit.load(silent: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PageHeader(
                    title: 'الحضور والانصراف',
                    decorated: true,
                    subtitle: AppFormat.dateLong(DateTime.now()),
                    actions: [
                      FilledButton.icon(
                        onPressed: () => _openEntry(context),
                        icon: const Icon(Icons.add),
                        label: const Text('تسجيل حضور'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const AttendanceFilters(),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
            const _RecordsSliver(),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        ),
      ),
    );
  }
}

Future<void> _openEntry(
  BuildContext context, {
  AttendanceRecord? record,
}) async {
  final cubit = context.read<AttendanceListCubit>();
  DateTime? savedDate;
  final saved = await showDialog<bool>(
    context: context,
    builder: (_) => AttendanceEntryDialog(
      employees: cubit.state.employees,
      record: record,
      onSave: (id, draft) {
        savedDate = draft.date;
        return cubit.saveRecord(recordId: id, draft: draft);
      },
    ),
  );
  if (saved == true && context.mounted) {
    final date = savedDate;
    if (date != null) {
      final selectedDate = dateOnly(date);
      final query = cubit.state.query;
      if (selectedDate.isBefore(dateOnly(query.from)) ||
          selectedDate.isAfter(dateOnly(query.to))) {
        await cubit.setRange(selectedDate, selectedDate);
      }
    }
    if (!context.mounted) return;
    await AppFeedback.success(
      context,
      illustration: AppIllustration.successAttendance,
      title: record == null ? 'تم تسجيل الحضور' : 'تم تحديث سجل الحضور',
    );
  }
}

class _RecordsSliver extends StatelessWidget {
  const _RecordsSliver();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceListCubit, AttendanceListState>(
      builder: (context, state) {
        final cubit = context.read<AttendanceListCubit>();
        final failure = state.failure;

        if (state.status == ViewStatus.failure && failure != null) {
          return SliverToBoxAdapter(
            child: ErrorView(failure: failure, onRetry: cubit.load),
          );
        }
        if (state.records.isEmpty) {
          if (state.status == ViewStatus.initial ||
              state.status == ViewStatus.loading) {
            return const SliverToBoxAdapter(child: LoadingView());
          }
          return SliverToBoxAdapter(
            child: IllustratedEmptyView(
              illustration: AppIllustration.emptyAttendance,
              action: cubit.hasCustomFilters
                  ? OutlinedButton(
                      onPressed: cubit.resetFilters,
                      child: const Text('العودة إلى اليوم'),
                    )
                  : null,
            ),
          );
        }

        final records = state.records;
        return SliverMainAxisGroup(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  '${AppFormat.number(records.length)} سجل',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AttendanceRecordTile(
                    record: records[index],
                    onEdit: () => _openEntry(context, record: records[index]),
                  ),
                ),
                childCount: records.length,
              ),
            ),
          ],
        );
      },
    );
  }
}
