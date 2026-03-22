class Routes {
  static const String login = '/login';
  static const String home = '/';
  static const String agenda = '/agenda';
  static const String agendaDay = '/agenda/day';
  static const String patients = '/patients';
  static const String dashboard = '/dashboard';

  static String agendaDayPath(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$agendaDay/$y-$m-$d';
  }
}
