import 'package:go_router/go_router.dart';
import 'package:mashwar_customer/features/home/presentation/pages/home_page.dart';

abstract final class AppRoutes {
  static const home = '/';
}

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
  ],
);
