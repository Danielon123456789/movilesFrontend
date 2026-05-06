import 'package:flutter_riverpod/flutter_riverpod.dart';

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

List<DateTime> weekContaining(DateTime date) {
  final sundayOffset = date.weekday % 7;
  final sunday = date.subtract(Duration(days: sundayOffset));
  return List.generate(7, (i) => sunday.add(Duration(days: i)));
}
