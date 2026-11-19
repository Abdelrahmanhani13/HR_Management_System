import 'package:flutter/material.dart';
import 'package:hr_management/core/widgets/state_views.dart';

/// Shown while the session status is still unknown (app start).
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: LoadingView());
  }
}
