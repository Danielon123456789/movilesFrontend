import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/therapist.dart';

class TherapistsState {
  const TherapistsState({
    required this.therapists,
    required this.query,
  });

  final List<Therapist> therapists;
  final String query;

  TherapistsState copyWith({
    List<Therapist>? therapists,
    String? query,
  }) {
    return TherapistsState(
      therapists: therapists ?? this.therapists,
      query: query ?? this.query,
    );
  }
}

class TherapistsController extends Notifier<TherapistsState> {
  @override
  TherapistsState build() {
    return const TherapistsState(
      therapists: _mockTherapists,
      query: '',
    );
  }

  void setQuery(String value) {
    state = state.copyWith(query: value);
  }
}

const _mockTherapists = [
  Therapist(
    id: '1',
    name: 'Dr. Juan Pérez',
    specialty: 'Fisioterapia',
    email: 'juan.perez@clinica.con',
    initials: 'DJP',
    schedule: [
      TherapistSchedule(day: 'Lun', timeRange: '07:00 - 15:00'),
      TherapistSchedule(day: 'Mar', timeRange: '07:00 - 15:00'),
      TherapistSchedule(day: 'Mié', timeRange: '07:00 - 15:00'),
      TherapistSchedule(day: 'Jue', timeRange: '07:00 - 15:00'),
      TherapistSchedule(day: 'Vie', timeRange: '07:00 - 15:00'),
    ],
  ),
  Therapist(
    id: '2',
    name: 'Dra. Laura Sánchez',
    specialty: 'Psicología Clínica',
    email: 'laura.sanchez@clinica.cor',
    initials: 'DLS',
    schedule: [
      TherapistSchedule(day: 'Lun', timeRange: '09:00 - 18:00'),
      TherapistSchedule(day: 'Mié', timeRange: '09:00 - 18:00'),
      TherapistSchedule(day: 'Vie', timeRange: '09:00 - 18:00'),
    ],
  ),
  Therapist(
    id: '3',
    name: 'Dr. Carlos Ramírez',
    specialty: 'Quiropráctica',
    email: 'carlos.ramirez@clinica.com',
    initials: 'DCR',
    schedule: [
      TherapistSchedule(day: 'Mar', timeRange: '08:00 - 16:00'),
      TherapistSchedule(day: 'Jue', timeRange: '08:00 - 16:00'),
      TherapistSchedule(day: 'Sáb', timeRange: '09:00 - 13:00'),
    ],
  ),
];

final therapistsControllerProvider =
    NotifierProvider<TherapistsController, TherapistsState>(
  TherapistsController.new,
);

final filteredTherapistsProvider = Provider<List<Therapist>>((ref) {
  final state = ref.watch(therapistsControllerProvider);
  final q = state.query.trim().toLowerCase();

  if (q.isEmpty) return state.therapists;

  return state.therapists
      .where((t) =>
          t.name.toLowerCase().contains(q) ||
          t.specialty.toLowerCase().contains(q))
      .toList(growable: false);
});
