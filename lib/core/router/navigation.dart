import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

extension SafeNavigation on BuildContext {
  /// Pops when there is a page to go back to (optionally returning [result]),
  /// otherwise navigates to [fallback]. Handles deep links / page reloads.
  void popOrGo(String fallback, [Object? result]) {
    if (canPop()) {
      pop(result);
    } else {
      go(fallback);
    }
  }
}
