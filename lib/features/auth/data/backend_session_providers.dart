import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_client.dart';
import '../presentation/controllers/auth_controller.dart';
import 'backend_user_remote_datasource.dart';
import 'models/backend_user_model.dart';

/// Perfil backend del usuario JWT (cached por [FutureProvider]).
///
/// Vive en auth/data porque acopla Dio + modelo de API; cualquier feature puede
/// `ref.watch` para rol e id numéricos. Si falla la red / 401 / etc., devuelve
/// `null` y [log]/[debugPrint] sin bloquear la UI.
final currentBackendUserProvider = FutureProvider<BackendUserModel?>((
  ref,
) async {
  final appUser = ref.watch(
    authControllerProvider.select((s) => s.user),
  );
  if (appUser == null) return null;

  try {
    final dio = ref.watch(dioProvider);
    final remote = BackendUserRemoteDataSource(dio);
    return await remote.fetchCurrentUser();
  } catch (e, st) {
    debugPrint('currentBackendUserProvider: $e\n$st');
    return null;
  }
});
