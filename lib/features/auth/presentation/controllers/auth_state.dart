import '../../domain/app_user.dart';

class AuthState {
  const AuthState({
    required this.user,
    required this.isLoading,
    required this.errorMessage,
  });

  factory AuthState.initial() =>
      const AuthState(user: null, isLoading: false, errorMessage: null);

  final AppUser? user;
  final bool isLoading;
  final String? errorMessage;

  AuthState copyWith({
    AppUser? Function()? user,
    bool? isLoading,
    String? Function()? errorMessage,
  }) {
    return AuthState(
      user: user != null ? user() : this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}
