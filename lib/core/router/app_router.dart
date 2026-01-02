import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/main_navigation.dart';
import '../../features/github_contribution/presentation/screens/contribution_statistics_screen.dart';
import '../../features/github_contribution/domain/entities/contribution_statistics.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainNavigation(),
    ),
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
      path: '/settings',
      builder: (context, state) => const MainNavigation(),
    ),
  ],
);
