import 'package:bloc/bloc.dart';
import 'package:kamilnotes/services/auth/auth_provider.dart';
import 'package:kamilnotes/services/auth/bloc/auth_event.dart';
import 'package:kamilnotes/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialized()) {
    //Initialize
    on<AuthEventInitialize>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut(null));
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    });
    //LogIn
    on<AuthEventLogIn>((event, emit) async {
      final email = event.email;
      final password = event.password;
      try {
        final user = await provider.login(email: email, password: password);
        emit(AuthStateLoggedIn(user));
      } on Exception catch (e) {
        //note the use of on Exception
        emit(AuthStateLogoutFailure(e));
      }
    });
    //LogOut
    on<AuthEventLogOut>((event, emit) async {
      emit(const AuthStateUninitialized());
      try {
        await provider.signOut();
        emit(const AuthStateLoggedOut(null));
      } on Exception catch (e) {
        emit(AuthStateLogoutFailure(e));
      }
    });
  }
}
