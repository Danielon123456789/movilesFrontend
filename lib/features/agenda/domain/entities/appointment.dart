class Appointment {
  const Appointment({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.timeRange,
    required this.therapist,
  });

  final String id;
  final String title;
  final String category;
  final DateTime date;
  final String timeRange;
  final String therapist;
}
