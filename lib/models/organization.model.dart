import 'package:agenda/models/user.model.dart';

class Organization {
  final String name;
  final User creator;

  Organization({required this.name, required this.creator});

  factory Organization.fromJson(Map<String, dynamic> json) {
    return Organization(
      name: json['name'],
      creator: User.fromJson(json['creator']),
    );
  }
}
