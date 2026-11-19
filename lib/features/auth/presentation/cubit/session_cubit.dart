import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hr_management/core/error/failures.dart';
import 'package:hr_management/core/usecase/usecase.dart';
import 'package:hr_management/features/auth/domain/entities/auth_session.dart';
import 'package:hr_management/features/auth/domain/entities/auth_state_change.dart';
import 'package:hr_management/features/auth/domain/usecases/auth_usecases.dart';

enum SessionStatus { unknown, authenticated, unauthenticated }

class SessionState extends Equatable {
  const SessionState({
    this.status = SessionStatus.unknown,
    this.session,
    this.signOutFailure,
    this.isPasswordRecovery = false,
  });

  final SessionStatus status;
  final AuthSession? session;

  /// Set when the last sign-out attempt failed; the user stays signed in.
  final Failure? signOutFailure;
  final bool isPasswordRecovery;

  @override
  List<Object?> get props => [
    status,
    session,
    signOutFailure,
    isPasswordRecovery,
  ];
}

/// App-wide session holder. The router listens to it for redirects.
///
/// Session restoration and token refresh are handled by the Supabase data
/// source; this cubit reacts to its state changes and operation results.
class SessionCubit extends Cubit<SessionState> {
  SessionCubit({
    required RestoreSession restoreSession,
    required SignOut signOut,
    required ObserveAuthState observeAuthState,
  }) : _restoreSession = restoreSession,
       _signOut = signOut,
       _observeAuthState = observeAuthState,
       super(const SessionState());

  final RestoreSession _restoreSession;
  final SignOut _signOut;
  final ObserveAuthState _observeAuthState;

  StreamSubscription<AuthStateChange>? _subscription;

  /// Call once at app start.
  Future<void> start() async {
    await _subscription?.cancel();
    _subscription = _observeAuthState().listen(_onAuthChanged);

    final result = await _restoreSession(const NoParams());
    result.fold(
      // Restoration is unavailable or failed: treat as signed out, unless the
      // auth stream already told us otherwise.
      (_) => _markUnauthenticatedIfUnknown(),
      (session) {
        if (session == null) {
          _markUnauthenticatedIfUnknown();
        } else {
          setSession(session);
        }
      },
    );
  }

  /// Called by the login flow (and by the auth stream) after a successful sign in.
  void setSession(AuthSession session) {
    emit(SessionState(status: SessionStatus.authenticated, session: session));
  }

  void clearPasswordRecovery() {
    emit(SessionState(status: state.status, session: state.session));
  }

  Future<void> signOut() async {
    // Clear any previous failure first so a repeated failure re-notifies.
    emit(SessionState(status: state.status, session: state.session));
    final result = await _signOut(const NoParams());
    result.fold(
      (failure) => emit(
        SessionState(
          status: state.status,
          session: state.session,
          signOutFailure: failure,
        ),
      ),
      (_) => emit(const SessionState(status: SessionStatus.unauthenticated)),
    );
  }

  void _onAuthChanged(AuthStateChange change) {
    final session = change.session;
    if (session == null) {
      emit(const SessionState(status: SessionStatus.unauthenticated));
    } else {
      emit(
        SessionState(
          status: SessionStatus.authenticated,
          session: session,
          isPasswordRecovery:
              change.isPasswordRecovery || state.isPasswordRecovery,
        ),
      );
    }
  }

  void _markUnauthenticatedIfUnknown() {
    if (state.status == SessionStatus.unknown) {
      emit(const SessionState(status: SessionStatus.unauthenticated));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
