import 'package:agenda/models/patient.model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agenda/core/network/api_exception.dart';

import '../../patients_providers.dart';

class PatientsState {
  const PatientsState({
    required this.patients,
    required this.query,
    required this.isLoading,
    this.errorMessage,
  });

  final List<Patient> patients;
  final String query;
  final bool isLoading;
  final String? errorMessage;

  PatientsState copyWith({
    List<Patient>? patients,
    String? query,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return PatientsState(
      patients: patients ?? this.patients,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

class PatientsController extends Notifier<PatientsState> {
  bool get _alive => ref.mounted;

  @override
  PatientsState build() {
    Future.microtask(_loadInitial);
    return const PatientsState(
      patients: [],
      query: '',
      isLoading: true,
      errorMessage: null,
    );
  }

  Future<void> _loadInitial() async {
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
      state = state.copyWith(isLoading: false, errorMessage: () => e.message);
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

  Future<void> removePatient(int id) {
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
        state = state.copyWith(isLoading: false, errorMessage: () => e.message);
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
    int id, {
    String? name,
    String? email,
    String? phoneNumber,
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
        );
        if (!_alive) return;
        final idx = state.patients.indexWhere((p) => p.id == id);
        if (idx < 0) {
          state = state.copyWith(isLoading: false, errorMessage: () => null);
          return;
        }
        final next = List<Patient>.from(state.patients);
        next[idx] = fresh;
        state = state.copyWith(
          patients: next,
          isLoading: false,
          errorMessage: () => null,
        );
      } on ApiException catch (e) {
        if (!_alive) return;
        state = state.copyWith(isLoading: false, errorMessage: () => e.message);
      } catch (e) {
        if (!_alive) return;
        state = state.copyWith(
          isLoading: false,
          errorMessage: () => 'Error inesperado: $e',
        );
      }
    });
  }

  Future<void> addPatient({required String name}) {
    return Future.microtask(() async {
      final repo = ref.read(patientsRepositoryProvider);
      state = state.copyWith(isLoading: true, errorMessage: () => null);
      try {
        final patient = await repo.createPatient(name: name);
        if (!_alive) return;
        state = state.copyWith(
          patients: [patient, ...state.patients],
          isLoading: false,
          errorMessage: () => null,
        );
      } on ApiException catch (e) {
        if (!_alive) return;
        state = state.copyWith(isLoading: false, errorMessage: () => e.message);
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
  final q = state.query.trim().toLowerCase();
  if (q.isNotEmpty) {
    items = items.where((p) => p.name.toLowerCase().contains(q));
  }

  return items.toList(growable: false);
});
