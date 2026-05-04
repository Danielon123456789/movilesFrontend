import 'package:agenda/core/network/dio_client.dart';
import 'package:agenda/models/user.model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserController {
  final Ref _ref;

  UserController(this._ref);

  Future<User> getMyData() async {
    final dio = _ref.read(dioProvider);
    final response = await dio.get('/users/me');
    return User.fromJson(response.data);
  }

  Future<User> getById(int id) async {
    final dio = _ref.read(dioProvider);
    final response = await dio.get('/users/$id');
    return User.fromJson(response.data);
  }

  Future<List<User>> getByQuery(String query, String role) async {
    final dio = _ref.read(dioProvider);
    final response = await dio.get(
      '/users',
      queryParameters: {'query': query, 'role': role},
    );
    return (response.data as List).map((json) => User.fromJson(json)).toList();
  }
}

final userControllerProvider = Provider((ref) => UserController(ref));
