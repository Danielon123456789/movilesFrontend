import 'package:agenda/core/network/dio_client.dart';
import 'package:agenda/models/organization.model.dart';
import 'package:agenda/models/user.model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrganizationController {
  final Ref _ref;

  OrganizationController(this._ref);

  Future<Organization> create({required String name}) async {
    final dio = _ref.read(dioProvider);
    final response = await dio.post('/organizations', data: {'name': name});
    return Organization.fromJson(response.data);
  }

  Future<Organization> getMyOrganization() async {
    final dio = _ref.read(dioProvider);
    final response = await dio.get('/organizations/mine');
    return Organization.fromJson(response.data);
  }

  Future<User> updateUserRole(String email, String role) async {
    final dio = _ref.read(dioProvider);
    final response = await dio.put(
      '/organizations/role',
      data: {'email': email, 'role': role},
    );
    return User.fromJson(response.data);
  }
}

final organizationControllerProvider = Provider(
  (ref) => OrganizationController(ref),
);
