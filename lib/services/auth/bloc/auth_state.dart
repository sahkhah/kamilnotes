import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:kamilnotes/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized();
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;
  const AuthStateLoggedIn(this.user);
}

/* class AuthStateLoginFailure extends AuthState {
  final Exception exception;
  const AuthStateLoginFailure(this.exception);
} */

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering(this.exception);
}

//we want to make this state a generic state
class AuthStateLoggedOut extends AuthState with EquatableMixin {
  final Exception? exception;
  final bool
      isLoading; //a user can eiether be logged in or logged out; it means that if a user hasn't logged in even with a new user
  const AuthStateLoggedOut({required this.exception, required this.isLoading});

  @override
  List<Object?> get props =>
      [exception, isLoading]; //we need to produce various mutation of AuthStateLoggedOut with different version of exception and isloading
}

/* class AuthStateLogoutFailure extends AuthState {
  final Exception exception;
  const AuthStateLogoutFailure(this.exception);
} */
