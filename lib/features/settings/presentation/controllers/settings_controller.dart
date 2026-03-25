import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Treatment {
  const Treatment({
    required this.name,
    required this.durationMinutes,
    required this.color,
  });

  final String name;
  final int durationMinutes;
  final Color color;
}

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
  final List<Treatment> treatments;

  SettingsState copyWith({
    int? defaultDuration,
    bool? notificationsEnabled,
    String? reminderHours,
    List<Treatment>? treatments,
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
      treatments: [
        Treatment(
          name: 'Fisioterapia General',
          durationMinutes: 60,
          color: Color(0xFF2A9D8F),
        ),
        Treatment(
          name: 'Consulta Psicológica',
          durationMinutes: 90,
          color: Color(0xFF4A90D9),
        ),
        Treatment(
          name: 'Ajuste Quiropráctico',
          durationMinutes: 45,
          color: Color(0xFF9B59B6),
        ),
        Treatment(
          name: 'Masaje Terapéutico',
          durationMinutes: 120,
          color: Color(0xFFF39C12),
        ),
      ],
    );
  }

  void setDefaultDuration(int value) {
    state = state.copyWith(defaultDuration: value);
  }

  void toggleNotifications(bool value) {
    state = state.copyWith(notificationsEnabled: value);
  }

  void setReminderHours(String value) {
    state = state.copyWith(reminderHours: value);
  }
}

final settingsControllerProvider =
    NotifierProvider<SettingsController, SettingsState>(
  SettingsController.new,
);
