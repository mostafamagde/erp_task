part of 'auth_cubit.dart';

abstract class AuthState {
  const AuthState();


}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;

  const AuthAuthenticated(this.user);


}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

}

class AuthPasswordResetSent extends AuthState {}

class AuthEmailVerificationSent extends AuthState {} 