import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/main_navigation.dart';
import '../../features/github_contribution/presentation/screens/contribution_statistics_screen.dart';
import '../../features/github_contribution/presentation/screens/other_user_contribution_screen.dart';
import '../../features/github_contribution/presentation/screens/following_users_screen.dart';
import '../../features/github_contribution/domain/entities/contribution_statistics.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const MainNavigation()),
    GoRoute(
      path: '/statistics',
      pageBuilder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final statistics = extra['statistics'] as ContributionStatistics;
        final year = extra['year'] as int;
        return MaterialPage(
          key: state.pageKey,
          child: ContributionStatisticsScreen(
            statistics: statistics,
            year: year,
          ),
        );
      },
    ),
    GoRoute(
      path: '/user/:username',
      pageBuilder: (context, state) {
        final username = state.pathParameters['username']!;
        return MaterialPage(
          key: state.pageKey,
          child: OtherUserContributionScreen(username: username),
        );
      },
    ),
    GoRoute(
      path: '/following',
      builder: (context, state) => const FollowingUsersScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const MainNavigation(),
    ),
  ],
);
