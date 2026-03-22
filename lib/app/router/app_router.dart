import 'package:go_router/go_router.dart';

import '../../features/agenda/presentation/screens/agenda_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/patients/presentation/screens/patients_screen.dart';
import 'routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: Routes.login,
  routes: <RouteBase>[
    GoRoute(
      path: Routes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(path: Routes.home, builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: Routes.agenda,
      builder: (context, state) => const AgendaScreen(),
    ),
    GoRoute(
      path: Routes.patients,
      builder: (context, state) => const PatientsScreen(),
    ),
    GoRoute(
      path: Routes.dashboard,
      builder: (context, state) => const DashboardScreen(),
    ),
  ],
);
