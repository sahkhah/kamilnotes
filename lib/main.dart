import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kamilnotes/constants/routes.dart';
import 'package:kamilnotes/services/auth/bloc/auth_bloc.dart';
import 'package:kamilnotes/services/auth/bloc/auth_event.dart';
import 'package:kamilnotes/services/auth/bloc/auth_state.dart';
import 'package:kamilnotes/services/auth/firebasse_auth_provider.dart';
import 'package:kamilnotes/views/login_view.dart';
import 'package:kamilnotes/views/notes/create_update_note_view.dart';
import 'package:kamilnotes/views/notes/note_view.dart';
import 'package:kamilnotes/views/register_view.dart';
import 'package:kamilnotes/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
      title: 'Homepage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegisterView(),
        noteRoute: (context) => const NoteView(),
        verifyEmailRoute: (context) => const EmailVerificationView(),
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const Homepage(),
      )));
}

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    context.read().add(const AuthEventInitialize());
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NoteView();
        } else if (state is AuthStateNeedsVerification) {
          return const EmailVerificationView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()), //if it's non of these states? just keep on loading
          );
        }
      },
    );
    /*  FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            ///get the current user
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const NoteView();
              } else {
                return const EmailVerificationView();
              }
            } else {
              return const LoginView();
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }); */
  }
}
