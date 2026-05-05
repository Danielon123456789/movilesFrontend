import 'package:agenda/features/auth/data/auth_repository.dart';
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
        // X-Google-Access-Token header used for Google Calendar connection in backend
        if (user != null &&
            user.email != null &&
            user.email!.endsWith('@gmail.com')) {
          final (_, googleAccessToken) = await ref
              .read(authRepositoryProvider)
              .signInWithGoogle();
          if (googleAccessToken != null) {
            options.headers['X-Google-Access-Token'] = googleAccessToken;
          }
        }
        handler.next(options);
      },
    ),
  );

  return dio;
});
