import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';
import 'auth_state.dart';

class AuthController extends Notifier<AuthState> {
  StreamSubscription<dynamic>? _authSub;

  @override
  AuthState build() {
    _authSub?.cancel();
    _authSub = ref.read(authRepositoryProvider).authStateChanges().listen((
      appUser,
    ) {
      if (!state.isLoading) {
        state = state.copyWith(user: () => appUser);
      }
    });

    ref.onDispose(() => _authSub?.cancel());

    return AuthState.initial();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signIn(email, password);
      state = state.copyWith(user: () => user, isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => _mapError(e.code),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Error inesperado: $e',
      );
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signUp(email, password);
      state = state.copyWith(user: () => user, isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => _mapError(e.code),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Error inesperado: $e',
      );
    }
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: () => null);
    try {
      final (user, _) = await ref.read(authRepositoryProvider).signInWithGoogle();
      state = state.copyWith(user: () => user, isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => _mapError(e.code),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Error inesperado: $e',
      );
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).signOut();
    state = AuthState.initial();
  }

  static String _mapError(String code) {
    return switch (code) {
      'user-not-found' => 'Usuario no encontrado.',
      'wrong-password' => 'Contraseña incorrecta.',
      'email-already-in-use' => 'El correo ya está registrado.',
      'invalid-email' => 'Correo electrónico inválido.',
      'weak-password' => 'La contraseña es muy débil.',
      'invalid-credential' => 'Credenciales inválidas.',
      'sign_in_canceled' => 'Inicio de sesión con Google cancelado.',
      'popup_closed_by_user' => 'Inicio de sesión con Google cancelado.',
      _ => 'Error de autenticación ($code).',
    };
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
