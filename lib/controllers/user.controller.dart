import 'package:agenda/core/network/dio_client.dart';
import 'package:agenda/models/user.model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserController {
  final Dio _dio;
  final _prefix = '/api/v1/users';

  UserController(Ref ref) : _dio = ref.read(dioProvider);

  Future<User> getMyData() async {
    final response = await _dio.get('$_prefix/me');
    return User.fromJson(response.data);
  }

  Future<User> getById(int id) async {
    final response = await _dio.get('$_prefix/$id');
    return User.fromJson(response.data);
  }

  Future<List<User>> getByQuery(String query, String role) async {
    final response = await _dio.get(
      _prefix,
      queryParameters: {'query': query, 'role': role},
    );
    return (response.data as List).map((json) => User.fromJson(json)).toList();
  }
}

final userControllerProvider = Provider((ref) => UserController(ref));
