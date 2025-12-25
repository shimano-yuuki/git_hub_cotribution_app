import 'package:go_router/go_router.dart';
import '../../shared/widgets/main_navigation.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const MainNavigation()),
  ],
);
