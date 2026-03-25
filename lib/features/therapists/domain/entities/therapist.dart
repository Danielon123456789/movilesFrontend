class TherapistSchedule {
  const TherapistSchedule({
    required this.day,
    required this.timeRange,
  });

  final String day;
  final String timeRange;
}

class Therapist {
  const Therapist({
    required this.id,
    required this.name,
    required this.specialty,
    required this.email,
    required this.initials,
    required this.schedule,
  });

  final String id;
  final String name;
  final String specialty;
  final String email;
  final String initials;
  final List<TherapistSchedule> schedule;
}
