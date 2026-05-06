import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agenda/core/network/api_exception.dart';

import '../../domain/entities/patient.dart';
import '../../patients_providers.dart';

enum PatientsFilter { all, active, inactive }

class PatientsState {
  const PatientsState({
    required this.patients,
    required this.query,
    required this.filter,
    required this.isLoading,
    this.errorMessage,
  });

  final List<Patient> patients;
  final String query;
  final PatientsFilter filter;
  final bool isLoading;
  final String? errorMessage;

  PatientsState copyWith({
    List<Patient>? patients,
    String? query,
    PatientsFilter? filter,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return PatientsState(
      patients: patients ?? this.patients,
      query: query ?? this.query,
      filter: filter ?? this.filter,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

class PatientsController extends Notifier<PatientsState> {
  /// Evita aplicar `state` tras `await` si el notifier ya se dispuso.
  bool get _alive => ref.mounted;

  @override
  PatientsState build() {
    Future.microtask(fetchPatients);
    return const PatientsState(
      patients: [],
      query: '',
      filter: PatientsFilter.all,
      isLoading: true,
      errorMessage: null,
    );
  }

  Future<void> fetchPatients() async {
    final repo = ref.read(patientsRepositoryProvider);
    try {
      final list = await repo.fetchPatients();
      if (!_alive) return;
      state = state.copyWith(
        patients: list,
        isLoading: false,
        errorMessage: () => null,
      );
    } on ApiException catch (e) {
      if (!_alive) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => e.message,
      );
    } catch (e) {
      if (!_alive) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Error inesperado: $e',
      );
    }
  }

  void setQuery(String value) {
    state = state.copyWith(query: value);
  }

  void setFilter(PatientsFilter value) {
    state = state.copyWith(filter: value);
  }

  Future<void> removePatient(String id) {
    return Future.microtask(() async {
      final repo = ref.read(patientsRepositoryProvider);
      state = state.copyWith(isLoading: true, errorMessage: () => null);
      try {
        await repo.deletePatient(id);
        if (!_alive) return;
        state = state.copyWith(
          patients: state.patients.where((p) => p.id != id).toList(),
          isLoading: false,
          errorMessage: () => null,
        );
      } on ApiException catch (e) {
        if (!_alive) return;
        state = state.copyWith(
          isLoading: false,
          errorMessage: () => e.message,
        );
      } catch (e) {
        if (!_alive) return;
        state = state.copyWith(
          isLoading: false,
          errorMessage: () => 'Error inesperado: $e',
        );
      }
    });
  }

  Future<void> updatePatient(
    String id, {
    String? name,
    String? email,
    String? phoneNumber,
    bool? active,
    // Solo sesión UI; no se persiste en el backend (ver TODO en merge).
    String? serviceLabel,
  }) {
    return Future.microtask(() async {
      final repo = ref.read(patientsRepositoryProvider);
      state = state.copyWith(isLoading: true, errorMessage: () => null);
      try {
        final fresh = await repo.updatePatient(
          id,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
          active: active,
        );
        if (!_alive) return;
        final idx = state.patients.indexWhere((p) => p.id == id);
        if (idx < 0) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: () => null,
          );
          return;
        }
        final oldPatient = state.patients[idx];
        // TODO(ui-session): `serviceLabel` no se persiste en el backend; solo en memoria.
        // Tras reiniciar la app, vendrá el placeholder del repositorio.
        final merged = fresh.copyWith(
          daysLabel: oldPatient.daysLabel,
          serviceLabel: serviceLabel ?? oldPatient.serviceLabel,
        );
        final next = List<Patient>.from(state.patients);
        next[idx] = merged;
        state = state.copyWith(
          patients: next,
          isLoading: false,
          errorMessage: () => null,
        );
      } on ApiException catch (e) {
        if (!_alive) return;
        state = state.copyWith(
          isLoading: false,
          errorMessage: () => e.message,
        );
      } catch (e) {
        if (!_alive) return;
        state = state.copyWith(
          isLoading: false,
          errorMessage: () => 'Error inesperado: $e',
        );
      }
    });
  }

  Future<void> addPatient({
    required String name,
    required String serviceLabel,
    String? email,
    String? phoneNumber,
  }) {
    // TODO(ui-session): `serviceLabel` no se persiste en el backend; solo se muestra en memoria
    // durante esta sesión. Tras reiniciar la app, el paciente tendrá el placeholder del repositorio.
    return Future.microtask(() async {
      final repo = ref.read(patientsRepositoryProvider);
      state = state.copyWith(isLoading: true, errorMessage: () => null);
      try {
        final patient = await repo.createPatient(
          name: name,
          serviceLabel: serviceLabel,
          email: email,
          phoneNumber: phoneNumber,
        );
        if (!_alive) return;
        state = state.copyWith(
          patients: [patient, ...state.patients],
          isLoading: false,
          errorMessage: () => null,
        );
      } on ApiException catch (e) {
        if (!_alive) return;
        state = state.copyWith(
          isLoading: false,
          errorMessage: () => e.message,
        );
      } catch (e) {
        if (!_alive) return;
        state = state.copyWith(
          isLoading: false,
          errorMessage: () => 'Error inesperado: $e',
        );
      }
    });
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
