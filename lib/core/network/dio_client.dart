import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../constants/app_constants.dart';

class DioClient {
  DioClient._();

  static Dio create() {
    return Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
      ),
    );
  }
}

