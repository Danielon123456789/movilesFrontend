import 'package:flutter_riverpod/legacy.dart';

class Notification {
  final String title;
  final String description;

  Notification({required this.title, required this.description});
}

class NotificationProvider extends StateNotifier<List<Notification>> {
  NotificationProvider() : super([]);

  void addItem({required String title, required String description}) {
    final newItem = Notification(title: title, description: description);
    state = [...state, newItem];
  }

  List<Notification> getAllItems() {
    return state;
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationProvider, List<Notification>>((ref) {
      return NotificationProvider();
    });
