import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:agenda/features/services/domain/entities/service.dart';
import 'package:agenda/features/services/services_providers.dart';

class SettingsState {
  const SettingsState({
    required this.defaultDuration,
    required this.notificationsEnabled,
    required this.reminderHours,
    required this.treatments,
  });

  final int defaultDuration;
  final bool notificationsEnabled;
  final String reminderHours;
  final List<Service> treatments;

  SettingsState copyWith({
    int? defaultDuration,
    bool? notificationsEnabled,
    String? reminderHours,
    List<Service>? treatments,
  }) {
    return SettingsState(
      defaultDuration: defaultDuration ?? this.defaultDuration,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderHours: reminderHours ?? this.reminderHours,
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
      reminderHours: '',
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

  void setReminderHours(String value) {
    state = state.copyWith(reminderHours: value);
  }

  Future<void> addTreatment(String name, int duration) async {
    final repo = ref.read(servicesRepositoryProvider);
    final created = await repo.createService(name: name, duration: duration);
    ref.invalidate(servicesListProvider);
    state = state.copyWith(treatments: [...state.treatments, created]);
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(SettingsController.new);
