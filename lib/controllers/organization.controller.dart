import 'package:agenda/core/network/dio_client.dart';
import 'package:agenda/models/organization.model.dart';
import 'package:agenda/models/user.model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrganizationController {
  final Dio _dio;
  final _prefix = '/api/v1/organizations';

  OrganizationController(Ref ref) : _dio = ref.read(dioProvider);

  Future<Organization> create({required String name}) async {
    final response = await _dio.post(_prefix, data: {'name': name});
    return Organization.fromJson(response.data);
  }

  Future<Organization> getMyOrganization() async {
    final response = await _dio.get('$_prefix/mine');
    return Organization.fromJson(response.data);
  }

  Future<User> updateUserRole(String email, String role) async {
    final response = await _dio.put(
      '$_prefix/role',
      data: {'email': email, 'role': role},
    );
    return User.fromJson(response.data);
  }
}

final organizationControllerProvider = Provider(
  (ref) => OrganizationController(ref),
);
