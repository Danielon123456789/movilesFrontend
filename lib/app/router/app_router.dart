import 'package:agenda/models/patient.model.dart';
import 'package:go_router/go_router.dart';

import '../../features/agenda/domain/entities/appointment.dart';
import '../../features/agenda/presentation/screens/agenda_screen.dart';
import '../../features/agenda/presentation/screens/appointment_detail_screen.dart';
import '../../features/agenda/presentation/screens/daily_agenda_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/treatments_screen.dart';
import '../../features/therapists/presentation/screens/therapists_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/patients/presentation/screens/patient_detail_screen.dart';
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
      routes: [
        GoRoute(
          path: 'day/:date',
          builder: (context, state) {
            final dateStr = state.pathParameters['date']!;
            final date = DateTime.parse(dateStr);
            return DailyAgendaScreen(selectedDate: date);
          },
        ),
        GoRoute(
          path: 'detail',
          builder: (context, state) {
            final appointment = state.extra! as Appointment;
            return AppointmentDetailScreen(appointment: appointment);
          },
        ),
      ],
    ),
    GoRoute(
      path: Routes.patients,
      builder: (context, state) => const PatientsScreen(),
      routes: [
        GoRoute(
          path: 'detail',
          builder: (context, state) {
            final patient = state.extra! as Patient;
            return PatientDetailScreen(patient: patient);
          },
        ),
      ],
    ),
    GoRoute(
      path: Routes.therapists,
      builder: (context, state) => const TherapistsScreen(),
      routes: [
        GoRoute(
          path: 'treatments',
          builder: (context, state) => const TreatmentsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: Routes.dashboard,
      builder: (context, state) => const DashboardScreen(),
      routes: [
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
  ],
);
