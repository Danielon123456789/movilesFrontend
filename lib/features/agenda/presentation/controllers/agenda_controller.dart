import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/appointment.dart';

class AgendaState {
  const AgendaState({
    required this.visibleMonth,
    required this.selectedDate,
  });

  final DateTime visibleMonth;
  final DateTime selectedDate;

  AgendaState copyWith({
    DateTime? visibleMonth,
    DateTime? selectedDate,
  }) {
    return AgendaState(
      visibleMonth: visibleMonth ?? this.visibleMonth,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

class AgendaController extends Notifier<AgendaState> {
  @override
  AgendaState build() {
    final now = DateTime.now();
    return AgendaState(
      visibleMonth: DateTime(now.year, now.month),
      selectedDate: DateTime(now.year, now.month, now.day),
    );
  }

  void setMonth(DateTime month) {
    state = state.copyWith(visibleMonth: DateTime(month.year, month.month));
  }

  void previousMonth() {
    final m = state.visibleMonth;
    state = state.copyWith(
      visibleMonth: DateTime(m.year, m.month - 1),
    );
  }

  void nextMonth() {
    final m = state.visibleMonth;
    state = state.copyWith(
      visibleMonth: DateTime(m.year, m.month + 1),
    );
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }
}

final agendaControllerProvider =
    NotifierProvider<AgendaController, AgendaState>(AgendaController.new);

int _weekdayToSundayFirst(int dartWeekday) {
  return dartWeekday % 7;
}

int firstWeekdayOffset(DateTime month) {
  final first = DateTime(month.year, month.month, 1);
  return _weekdayToSundayFirst(first.weekday);
}

int daysInMonth(DateTime month) {
  return DateTime(month.year, month.month + 1, 0).day;
}

List<int?> visibleGridCells(DateTime month) {
  final offset = firstWeekdayOffset(month);
  final days = daysInMonth(month);
  final rowsNeeded = ((offset + days) / 7).ceil();
  final total = rowsNeeded * 7;
  final result = <int?>[];

  for (var i = 0; i < total; i++) {
    if (i < offset || i >= offset + days) {
      result.add(null);
    } else {
      result.add(i - offset + 1);
    }
  }
  return result;
}

bool _sameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

Set<int> _daysWithAppointments(List<Appointment> appointments, DateTime month) {
  final set = <int>{};
  for (final a in appointments) {
    if (a.date.year == month.year && a.date.month == month.month) {
      set.add(a.date.day);
    }
  }
  return set;
}

final mockAppointmentsProvider = Provider<List<Appointment>>((ref) {
  final now = DateTime.now();
  return [
    Appointment(
      id: '1',
      title: 'María González',
      category: 'Fisioterapia General',
      date: DateTime(now.year, now.month, 3),
      timeRange: '10:00 - 11:00',
      therapist: 'Daniel Hernández',
    ),
    Appointment(
      id: '2',
      title: 'Roberto Gómez',
      category: 'Ajuste Quiropráctico',
      date: DateTime(now.year, now.month, 10),
      timeRange: '09:00 - 09:45',
      therapist: 'Sergio Gómez',
    ),
    Appointment(
      id: '3',
      title: 'Carlos Rodríguez',
      category: 'Fisioterapia General',
      date: DateTime(now.year, now.month, 10),
      timeRange: '15:30 - 16:30',
      therapist: 'Roberto Gómez',
    ),
    Appointment(
      id: '4',
      title: 'Ana Martínez',
      category: 'Consulta',
      date: DateTime(now.year, now.month, 15),
      timeRange: '11:00 - 12:00',
      therapist: 'Carlos Rodríguez',
    ),
    Appointment(
      id: '5',
      title: 'Pedro Sánchez',
      category: 'Fisioterapia General',
      date: DateTime(now.year, now.month, 22),
      timeRange: '16:00 - 17:00',
      therapist: 'Daniel Hernández',
    ),
    Appointment(
      id: '6',
      title: 'Laura Fernández',
      category: 'Revisión',
      date: DateTime(now.year, now.month, 22),
      timeRange: '12:00 - 12:30',
      therapist: 'Sergio Gómez',
    ),
  ];
});

final appointmentsForSelectedDateProvider = Provider<List<Appointment>>((ref) {
  final state = ref.watch(agendaControllerProvider);
  final all = ref.watch(mockAppointmentsProvider);
  return all
      .where((a) => _sameDate(a.date, state.selectedDate))
      .toList(growable: false);
});

final appointmentsForDateProvider =
    Provider.family<List<Appointment>, DateTime>((ref, date) {
  final all = ref.watch(mockAppointmentsProvider);
  return all
      .where((a) => _sameDate(a.date, date))
      .toList(growable: false);
});

List<DateTime> weekContaining(DateTime date) {
  final sundayOffset = date.weekday % 7;
  final sunday = date.subtract(Duration(days: sundayOffset));
  return List.generate(7, (i) => sunday.add(Duration(days: i)));
}

final daysWithAppointmentsProvider = Provider<Set<int>>((ref) {
  final state = ref.watch(agendaControllerProvider);
  final appointments = ref.watch(mockAppointmentsProvider);
  return _daysWithAppointments(appointments, state.visibleMonth);
});
