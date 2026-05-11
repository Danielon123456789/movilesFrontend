import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agenda/features/services/domain/entities/service.dart';
import 'package:agenda/features/services/services_providers.dart';

class SettingsState {
  const SettingsState({
    required this.defaultDuration,
    required this.notificationsEnabled,
    required this.treatments,
  });

  final int defaultDuration;
  final bool notificationsEnabled;
  final List<Service> treatments;

  SettingsState copyWith({
    int? defaultDuration,
    bool? notificationsEnabled,
    List<Service>? treatments,
  }) {
    return SettingsState(
      defaultDuration: defaultDuration ?? this.defaultDuration,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      treatments: treatments ?? this.treatments,
    );
  }
}

class SettingsController extends Notifier<SettingsState> {
  @override
  SettingsState build() {
    return const SettingsState(
      defaultDuration: 60,
      notificationsEnabled: true,
      treatments: [],
    );
  }

  void setDefaultDuration(int value) {
    state = state.copyWith(defaultDuration: value);
  }

  void toggleNotifications(bool value) {
    state = state.copyWith(notificationsEnabled: value);
  }

  Future<void> fetchTreatments() async {
    final repo = ref.read(servicesRepositoryProvider);
    final list = await repo.fetchServices();
    state = state.copyWith(treatments: list);
  }

  /// Recarga tratamientos y [servicesListProvider] (equivale a [fetchTreatments] + invalidate).
  Future<void> refreshTreatmentsServices() async {
    await fetchTreatments();
    ref.invalidate(servicesListProvider);
  }

  Future<void> addTreatment(String name, int duration) async {
    final repo = ref.read(servicesRepositoryProvider);
    final created = await repo.createService(name: name, duration: duration);
    ref.invalidate(servicesListProvider);
    state = state.copyWith(treatments: [...state.treatments, created]);
  }

  Future<void> editTreatment(
    String id, {
    String? name,
    int? duration,
  }) async {
    final repo = ref.read(servicesRepositoryProvider);
    final updated = await repo.updateService(id, name: name, duration: duration);
    final idx = state.treatments.indexWhere((t) => t.id == id);
    if (idx < 0) return;
    final next = List<Service>.from(state.treatments)..[idx] = updated;
    state = state.copyWith(treatments: next);
    ref.invalidate(servicesListProvider);
  }

  Future<void> removeTreatment(String id) async {
    final repo = ref.read(servicesRepositoryProvider);
    await repo.deleteService(id);
    state = state.copyWith(
      treatments: state.treatments.where((t) => t.id != id).toList(),
    );
    ref.invalidate(servicesListProvider);
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);
