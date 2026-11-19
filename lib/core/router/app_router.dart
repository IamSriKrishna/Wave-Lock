
import 'package:go_router/go_router.dart';

import '../../features/strict_mode/presentation/pages/strict_mode_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/strict-mode',
  routes: [
    GoRoute(
      path: '/strict-mode',
      name: 'strict-mode',
      builder: (context, state) => const StrictModePage(),
    ),
  ],
);
