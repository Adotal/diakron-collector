// Routes manager
import 'package:diakron_collectors/data/repositories/auth/auth_repository.dart';
import 'package:diakron_collectors/data/repositories/map/map_repository_impl.dart';
import 'package:diakron_collectors/data/repositories/user/collector_repository.dart';
import 'package:diakron_collectors/routing/routes.dart';
import 'package:diakron_collectors/ui/auth/forgot_password/view_models/forgot_password_viewmodel.dart';
import 'package:diakron_collectors/ui/auth/forgot_password/widgets/forgot_password_screen.dart';
import 'package:diakron_collectors/ui/auth/login/view_models/login_viewmodel.dart';
import 'package:diakron_collectors/ui/auth/login/widgets/login_screen.dart';
import 'package:diakron_collectors/ui/auth/reset_password/view_models/reset_password_viewmodel.dart';
import 'package:diakron_collectors/ui/auth/reset_password/widgets/reset_password_screen.dart';
import 'package:diakron_collectors/ui/auth/sigunp/view_models/signup_viewmodel.dart';
import 'package:diakron_collectors/ui/auth/sigunp/widgets/signup_screen.dart';
import 'package:diakron_collectors/ui/home/view_models/home_viewmodel.dart';
import 'package:diakron_collectors/ui/home/widgets/home_screen.dart';
import 'package:diakron_collectors/ui/main/widgets/main_screen.dart';
import 'package:diakron_collectors/ui/map/view_models/map_viewmodel.dart';
import 'package:diakron_collectors/ui/map/widgets/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

GoRouter router(AuthRepository authRepository) => GoRouter(
  initialLocation: Routes.home,
  debugLogDiagnostics: true, // TESTING
  refreshListenable: authRepository,
  redirect: _redirect,

  routes: [
    GoRoute(
      path: Routes.login,
      builder: (context, state) {
        final viewModel = LoginViewModel(
          authRepository: context.read<AuthRepository>(),
        );
        return LoginScreen(viewModel: viewModel);
      },
    ),

    ShellRoute(
      builder: (context, state, child) {
        return MainScreen(child: child);
      },
      routes: [
        GoRoute(
          path: Routes.home,
          pageBuilder: (context, state) {
            return CustomTransitionPage(
              key: state.pageKey,
              // Wrap the Home branch in the Provider so it stays alive during navigation
              child: Builder(
                builder: (context) {
                  // Use context.read()
                  final viewModel = HomeViewModel(
                    authRepository: context.read<AuthRepository>(),
                  );
                  return HomeScreen(viewModel: viewModel);
                },
              ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
            );
          },
        ),
        GoRoute(
          path: Routes.activity,
          builder: (context, state) {
            // final viewModel = ScannerViewModel(
            //   authRepository: context.read<AuthRepository>(),
            //   participantRepository: context.read<ParticipantRepository>(),
            // );
            // return ScannerScreen(viewModel: viewModel);
            return Scaffold(body: Text('activity'));
          },
        ),
        GoRoute(
          path: Routes.scanner,
          builder: (context, state) {
            // final viewModel = ScannerViewModel(
            //   authRepository: context.read<AuthRepository>(),
            //   participantRepository: context.read<ParticipantRepository>(),
            // );
            // return ScannerScreen(viewModel: viewModel);
            return Scaffold(body: Text('scanner'),);
          },
        ),

          GoRoute(
          path: Routes.map,
          builder: (context, state) {
            final viewModel = MapViewModel(
              mapRepository: MapRepositoryImpl(),
              collectorRepository: context.read<CollectorRepository>(),
            );
            return MapScreen(viewModel: viewModel);
          },
        ),

        GoRoute(
          path: Routes.profile,
          builder: (context, state) {
            // final viewModel = ScannerViewModel(
            //   authRepository: context.read<AuthRepository>(),
            //   participantRepository: context.read<ParticipantRepository>(),
            // );
            // return ScannerScreen(viewModel: viewModel);
            return Scaffold(body: Text('profile'),);
          },
        ),
      ],
    ),
    GoRoute(
      path: Routes.home,
      builder: (context, state) {
        return HomeScreen(
          viewModel: HomeViewModel(
            authRepository: context.read<AuthRepository>(),
          ),
        );
      },
    ),
    GoRoute(
      path: Routes.forgotpassword,
      builder: (context, state) {
        final viewModel = ForgotPasswordViewmodel(
          authRepository: context.read<AuthRepository>(),
        );
        return ForgotPasswordScreen(viewModel: viewModel);
      },
    ),
    GoRoute(
      path: Routes.resetpassword,
      builder: (context, state) {
        final viewModel = ResetPasswordViewmodel(
          authRepository: context.read<AuthRepository>(),
        );
        return ResetPasswordScreen(viewModel: viewModel);
      },
    ),
    GoRoute(
      path: Routes.signup,
      builder: (context, state) {
        final viewModel = SignupViewModel(
          authRepository: context.read<AuthRepository>(),
        );
        return SignupScreen(viewModel: viewModel);
      },
    ),
  ],
);

Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  final authRepo = context.read<AuthRepository>();

  final bool loggedIn = authRepo.isAuthenticated;
  // Auth Check
  final bool isAtAuthPage = [
    Routes.login,
    Routes.signup,
    Routes.forgotpassword,
    Routes.resetpassword,
  ].contains(state.matchedLocation);

  // // Locations
  final bool isAtLogin = state.matchedLocation == Routes.login;

  // Password Recovery
  if (authRepo.isRecoveringPassword) {
    return Routes.resetpassword;
  }

  // If not logged in and not in auth page go to Login
  if (!loggedIn) {
    return isAtAuthPage ? null : Routes.login;
  }

  if (authRepo.isVerifyingAuth) {
    return null;
  }

  // Logged in in login go Home
  if (loggedIn && isAtLogin) {
    return Routes.home;
  }

  return null;
}
