import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../constants/app_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: AppConstants.connectTimeout,
      receiveTimeout: AppConstants.receiveTimeout,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final firebaseToken = await user.getIdToken();
          options.headers['Authorization'] = 'Bearer $firebaseToken';
        }
        // No invocar signInWithGoogle() por request: bloqueaba Dio y el backend Nest
        // no consume X-Google-Access-Token en las rutas actuales.
        handler.next(options);
      },
    ),
  );

  return dio;
});
