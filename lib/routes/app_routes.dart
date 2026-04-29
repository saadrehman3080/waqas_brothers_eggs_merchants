import 'package:go_router/go_router.dart';

import '../views/home.dart';
import '../views/splash/splash_screen.dart';

class AppRoutes {
  AppRoutes._();
  static const String splash = '/';
  static const String home = '/home';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
