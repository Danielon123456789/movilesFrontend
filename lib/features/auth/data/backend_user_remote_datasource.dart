import 'package:dio/dio.dart';

import 'models/backend_user_model.dart';

class BackendUserRemoteDataSource {
  BackendUserRemoteDataSource(this._dio);

  final Dio _dio;

  static const _me = '/api/v1/users/me';

  Future<BackendUserModel> fetchCurrentUser() async {
    final response = await _dio.get(_me);
    return BackendUserModel.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}
