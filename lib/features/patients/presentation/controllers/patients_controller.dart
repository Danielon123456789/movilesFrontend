import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/patient.dart';

enum PatientsFilter { all, active, inactive }

class PatientsState {
  const PatientsState({
    required this.patients,
    required this.query,
    required this.filter,
    });

  final List<Patient> patients;
  final String query;
  final PatientsFilter filter;

  PatientsState copyWith({
    List<Patient>? patients,
    String? query,
    PatientsFilter? filter,
  }) {
    return PatientsState(
      patients: patients ?? this.patients,
      query: query ?? this.query,
      filter: filter ?? this.filter,
    );
  }
}

class PatientsController extends Notifier<PatientsState> {
  @override
  PatientsState build() {
    return PatientsState(
      patients: const [
        Patient(
          id: '1',
          name: 'María González',
          daysLabel: 'Lunes, Martes',
          serviceLabel: 'Fisioterapia General',
          isActive: true,
        ),
        Patient(
          id: '2',
          name: 'Roberto Gómez',
          daysLabel: 'Martes, Jueves',
          serviceLabel: 'Ajuste Quiropráctico',
          isActive: false,
        ),
        Patient(
          id: '3',
          name: 'Carlos Rodríguez',
          daysLabel: 'Viernes',
          serviceLabel: 'Fisioterapia General',
          isActive: true,
        ),
        Patient(
          id: '4',
          name: 'Ana Martínez',
          daysLabel: 'Sábado, Lunes',
          serviceLabel: 'Fisioterapia General',
          isActive: true,
        ),
      ],
      query: '',
      filter: PatientsFilter.all,
    );
  }

  void setQuery(String value) {
    state = state.copyWith(query: value);
  }

  void setFilter(PatientsFilter value) {
    state = state.copyWith(filter: value);
  }
}

final patientsControllerProvider =
    NotifierProvider<PatientsController, PatientsState>(PatientsController.new);

final filteredPatientsProvider = Provider<List<Patient>>((ref) {
  final state = ref.watch(patientsControllerProvider);

  Iterable<Patient> items = state.patients;
  switch (state.filter) {
    case PatientsFilter.all:
      break;
    case PatientsFilter.active:
      items = items.where((p) => p.isActive);
      break;
    case PatientsFilter.inactive:
      items = items.where((p) => !p.isActive);
      break;
  }

  final q = state.query.trim().toLowerCase();
  if (q.isNotEmpty) {
    items = items.where((p) => p.name.toLowerCase().contains(q));
  }

  return items.toList(growable: false);
});

