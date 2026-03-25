class Routes {
  static const String login = '/login';
  static const String home = '/';
  static const String agenda = '/agenda';
  static const String agendaDay = '/agenda/day';
  static const String appointmentDetail = '/agenda/detail';
  static const String patients = '/patients';
  static const String patientDetail = '/patients/detail';
  static const String therapists = '/therapists';
  static const String dashboard = '/dashboard';
  static const String settings = '/dashboard/settings';

  static String agendaDayPath(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$agendaDay/$y-$m-$d';
  }
}
