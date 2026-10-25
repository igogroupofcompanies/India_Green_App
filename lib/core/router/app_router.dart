import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'route_names.dart';
import 'route_transitions.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/onboarding/presentation/screens/language_selection_screen.dart';
import '../../features/onboarding/presentation/screens/role_selection_screen.dart';
import '../../features/onboarding/presentation/screens/otp_login_screen.dart';
import '../../features/onboarding/presentation/screens/user_details_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_shell.dart';
import '../../features/onboarding/providers/auth_provider.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/agrimart/presentation/screens/agrimart_screen.dart';
import '../../features/mandi_pricing/presentation/screens/mandi_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/projects/presentation/screens/projects_screen.dart';
import '../../features/projects/presentation/screens/agri_projects_screen.dart';
import '../../features/projects/presentation/screens/aquaculture_projects_screen.dart';
import '../../features/projects/presentation/screens/livestock_projects_screen.dart';
import '../../features/projects/presentation/screens/farm_engineering_projects_screen.dart';
import '../../features/learning/presentation/screens/learning_academy_screen.dart';
import '../../features/finance/presentation/screens/finance_screen.dart';
import '../../features/jobs/presentation/screens/jobs_screen.dart';
import '../../features/opportunities/presentation/screens/opportunities_screen.dart';
import '../../features/vendor/presentation/screens/vendor_dashboard_screen.dart';

/// GoRouter configuration with auth-aware redirects.
final appRouterProvider = Provider<GoRouter>((ref) {
  // One router instance for the app's lifetime; auth changes re-run `redirect`
  // through this listenable instead of rebuilding the router.
  final listenable = ValueNotifier<bool>(false);
  ref.onDispose(listenable.dispose);
  
  ref.listen<AuthState>(
    authProvider,
    (_, next) {
      listenable.value = !listenable.value; // trigger refresh
    },
  );

  return GoRouter(
    initialLocation: Routes.splash,
    debugLogDiagnostics: true,
    refreshListenable: listenable,
    redirect: (context, state) {
      // We must read here dynamically so it gets the latest value during redirect
      final isAuthenticated = ref.read(authProvider).isAuthenticated;
      final location = state.matchedLocation;
      final isOnboarding = location.startsWith('/onboarding');
      final isSplash = location == Routes.splash;

      if (!isAuthenticated && !isOnboarding && !isSplash) {
        return Routes.splash;
      }

      if (isAuthenticated && (isOnboarding || isSplash)) {
        return Routes.home;
      }

      return null;
    },
    routes: [
      // ── Unauthenticated ─────────────
      GoRoute(
        path: Routes.splash,
        pageBuilder: (context, state) =>
            fadeTransition(const SplashScreen(), state),
      ),
      GoRoute(
        path: Routes.languageSelect,
        pageBuilder: (context, state) =>
            slideUpTransition(const LanguageSelectionScreen(), state),
      ),
      GoRoute(
        path: Routes.roleSelect,
        pageBuilder: (context, state) =>
            slideUpTransition(const RoleSelectionScreen(), state),
      ),
      GoRoute(
        path: Routes.otpLogin,
        pageBuilder: (context, state) =>
            slideUpTransition(const OtpLoginScreen(), state),
      ),
      GoRoute(
        path: Routes.userDetails,
        pageBuilder: (context, state) =>
            slideUpTransition(const UserDetailsScreen(), state),
      ),

      // ── Authenticated Shell ─────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return DashboardShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.home,
              builder: (_, __) => const HomeScreen(),
            ),
          ]),

          // Branch 1: Market
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.agrimart,
              builder: (_, __) => const AgriMartScreen(),
            ),
          ]),

          // Branch 2: Mandi
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.mandi,
              builder: (_, __) => const MandiScreen(),
            ),
          ]),

          // Branch 3: Projects
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.projects,
              builder: (_, __) => const ProjectsScreen(),
              routes: [
                GoRoute(
                  path: 'agri-farming',
                  builder: (_, __) => const AgriProjectsScreen(),
                ),
                GoRoute(
                  path: 'aquaculture',
                  builder: (_, __) => const AquacultureProjectsScreen(),
                ),
                GoRoute(
                  path: 'livestock',
                  builder: (_, __) => const LivestockProjectsScreen(),
                ),
                GoRoute(
                  path: 'farm-engineering',
                  builder: (_, __) => const FarmEngineeringProjectsScreen(),
                ),
              ],
            ),
          ]),

          // Branch 4: Hubs
          StatefulShellBranch(routes: [
            GoRoute(
              path: Routes.hubs,
              redirect: (_, __) => Routes.profile,
            ),
            GoRoute(
              path: Routes.profile,
              builder: (_, __) => const ProfileScreen(),
            ),
            GoRoute(
              path: Routes.vendor,
              builder: (_, __) => const VendorDashboardScreen(),
            ),
            GoRoute(
              path: Routes.finance,
              builder: (_, __) => const FinanceScreen(),
            ),
            GoRoute(
              path: Routes.learn,
              builder: (_, __) => const LearningAcademyScreen(),
            ),
            GoRoute(
              path: Routes.jobs,
              builder: (_, __) => const JobsScreen(),
            ),
            GoRoute(
              path: Routes.opportunities,
              builder: (_, __) => const OpportunitiesScreen(),
            ),
          ]),
        ],
      ),
    ],
  );
});


