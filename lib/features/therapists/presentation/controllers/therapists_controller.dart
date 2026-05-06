import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agenda/core/network/api_exception.dart';

import '../../domain/entities/therapist.dart';
import '../../therapists_providers.dart';

class TherapistsState {
  const TherapistsState({
    required this.therapists,
    required this.query,
    required this.isLoading,
    this.errorMessage,
  });

  final List<Therapist> therapists;
  final String query;
  final bool isLoading;
  final String? errorMessage;

  TherapistsState copyWith({
    List<Therapist>? therapists,
    String? query,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return TherapistsState(
      therapists: therapists ?? this.therapists,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

class TherapistsController extends Notifier<TherapistsState> {
  bool get _alive => ref.mounted;

  @override
  TherapistsState build() {
    Future.microtask(fetchTherapists);
    return const TherapistsState(
      therapists: [],
      query: '',
      isLoading: true,
      errorMessage: null,
    );
  }

  Future<void> fetchTherapists() async {
    final repo = ref.read(therapistsRepositoryProvider);
    try {
      final list = await repo.fetchTherapists();
      if (!_alive) return;
      state = state.copyWith(
        therapists: list,
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
        errorMessage: () => 'Error inesperado: \$e',
      );
    }
  }

  void setQuery(String value) {
    state = state.copyWith(query: value);
  }

  Future<void> removeTherapist(String id) {
    return Future.microtask(() async {
      final repo = ref.read(therapistsRepositoryProvider);
      state = state.copyWith(isLoading: true, errorMessage: () => null);
      try {
        await repo.deleteTherapist(id);
        if (!_alive) return;
        state = state.copyWith(
          therapists: state.therapists.where((t) => t.id != id).toList(),
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
          errorMessage: () => 'Error inesperado: \$e',
        );
      }
    });
  }

  Future<void> updateTherapist(
    String id, {
    String? name,
    String? email,
    String? phoneNumber,
    String? specialty,
  }) {
    return Future.microtask(() async {
      final repo = ref.read(therapistsRepositoryProvider);
      state = state.copyWith(isLoading: true, errorMessage: () => null);
      try {
        final fresh = await repo.updateTherapist(
          id,
          name: name,
          email: email,
          phoneNumber: phoneNumber,
        );
        if (!_alive) return;
        final idx = state.therapists.indexWhere((t) => t.id == id);
        if (idx < 0) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: () => null,
          );
          return;
        }
        final next = List<Therapist>.from(state.therapists);
        next[idx] = fresh;
        state = state.copyWith(
          therapists: next,
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
          errorMessage: () => 'Error inesperado: \$e',
        );
      }
    });
  }

  Future<void> addTherapist({
    required String name,
    String? email,
    String? phoneNumber,
    String? specialty,
  }) {
    return Future.microtask(() async {
      final repo = ref.read(therapistsRepositoryProvider);
      state = state.copyWith(isLoading: true, errorMessage: () => null);
      try {
        final therapist = await repo.createTherapist(
          name: name,
          email: email,
          phoneNumber: phoneNumber,
        );
        if (!_alive) return;
        state = state.copyWith(
          therapists: [therapist, ...state.therapists],
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
          errorMessage: () => 'Error inesperado: \$e',
        );
      }
    });
  }
}

final therapistsControllerProvider =
    NotifierProvider<TherapistsController, TherapistsState>(
      TherapistsController.new,
    );

final filteredTherapistsProvider = Provider<List<Therapist>>((ref) {
  final state = ref.watch(therapistsControllerProvider);
  final q = state.query.trim().toLowerCase();

  if (q.isEmpty) return state.therapists;

  return state.therapists
      .where(
        (t) =>
            t.name.toLowerCase().contains(q) ||
            t.specialty.toLowerCase().contains(q),
      )
      .toList(growable: false);
});
