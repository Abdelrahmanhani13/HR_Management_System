import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hr_management/core/router/app_routes.dart';
import 'package:hr_management/core/theme/app_spacing.dart';
import 'package:hr_management/core/utils/responsive.dart';
import 'package:hr_management/core/widgets/app_assets.dart';
import 'package:hr_management/core/widgets/feedback.dart';
import 'package:hr_management/features/auth/presentation/cubit/session_cubit.dart';
import 'package:hr_management/features/auth/presentation/widgets/sign_out_action.dart';

class _Destination {
  const _Destination(this.label, this.path, this.icon, this.selectedIcon);

  final String label;
  final String path;
  final IconData icon;
  final IconData selectedIcon;
}

const _destinations = [
  _Destination(
    'الرئيسية',
    AppRoutes.dashboard,
    Icons.space_dashboard_outlined,
    Icons.space_dashboard,
  ),
  _Destination(
    'الموظفون',
    AppRoutes.employees,
    Icons.groups_outlined,
    Icons.groups,
  ),
  _Destination(
    'الحضور',
    AppRoutes.attendance,
    Icons.event_available_outlined,
    Icons.event_available,
  ),
  _Destination(
    'الرواتب',
    AppRoutes.payroll,
    Icons.payments_outlined,
    Icons.payments,
  ),
  _Destination('حسابي', AppRoutes.profile, Icons.person_outline, Icons.person),
];

/// Navigation frame around the signed-in screens: a bottom bar on phones, a
/// rail on tablets and a labelled rail on desktops.
class AppShell extends StatelessWidget {
  const AppShell({required this.location, required this.child, super.key});

  final String location;
  final Widget child;

  int get _selectedIndex {
    final index = _destinations.indexWhere(
      (d) => location == d.path || location.startsWith('${d.path}/'),
    );
    return index < 0 ? 0 : index;
  }

  void _select(BuildContext context, int index) {
    final path = _destinations[index].path;
    if (path != location) context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    final size = Responsive.of(context);
    final index = _selectedIndex;
    final scheme = Theme.of(context).colorScheme;

    return BlocListener<SessionCubit, SessionState>(
      listenWhen: (p, c) =>
          c.signOutFailure != null && p.signOutFailure != c.signOutFailure,
      listener: (context, state) => showAppSnackBar(
        context,
        state.signOutFailure?.message ?? 'تعذر تسجيل الخروج.',
        isError: true,
      ),
      child: Scaffold(
        body: size == ScreenSize.compact
            ? child
            : Row(
                children: [
                  NavigationRail(
                    selectedIndex: index,
                    extended: size == ScreenSize.expanded,
                    backgroundColor: scheme.surface,
                    onDestinationSelected: (i) => _select(context, i),
                    leading: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      child: _Brand(extended: size == ScreenSize.expanded),
                    ),
                    trailing: Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: IconButton(
                            tooltip: 'تسجيل الخروج',
                            onPressed: () => confirmAndSignOut(context),
                            icon: const Icon(Icons.logout),
                          ),
                        ),
                      ),
                    ),
                    destinations: [
                      for (final d in _destinations)
                        NavigationRailDestination(
                          icon: Icon(d.icon),
                          selectedIcon: Icon(d.selectedIcon),
                          label: Text(d.label),
                        ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: child),
                ],
              ),
        bottomNavigationBar: size == ScreenSize.compact
            ? NavigationBar(
                selectedIndex: index,
                onDestinationSelected: (i) => _select(context, i),
                destinations: [
                  for (final d in _destinations)
                    NavigationDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: d.label,
                    ),
                ],
              )
            : null,
      ),
    );
  }
}

/// Company mark: the full logo on the extended rail, the emblem on the
/// collapsed one. Aspect ratios are preserved; nothing is stretched.
class _Brand extends StatelessWidget {
  const _Brand({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context) {
    if (extended) {
      return Image.asset(
        AppAssets.logo,
        width: 168,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        semanticLabel: 'Pioneers Digital Integration',
      );
    }
    return Image.asset(
      AppAssets.emblem,
      width: 44,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      semanticLabel: 'Pioneers',
    );
  }
}
