import 'package:flutter/material.dart';
import 'package:kamilnotes/constants/routes.dart';
import 'package:kamilnotes/services/auth/auth_services.dart';
import 'package:kamilnotes/views/login_view.dart';
import 'package:kamilnotes/views/notes/new_note_view.dart';
import 'package:kamilnotes/views/notes/note_view.dart';
import 'package:kamilnotes/views/register_view.dart';
import 'package:kamilnotes/views/verify_email_view.dart';

 

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const Homepage());
}

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Homepage',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes: {
          loginRoute: (context) => const LoginView(),
          registerRoute: (context) => const RegisterView(),
          noteRoute: (context) => const NoteView(),
          verifyEmailRoute: (context) => const EmailVerificationView(),
          newNoteRoute: (context) => const NewNoteView(),

        },
        home: FutureBuilder(
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
            }));
  }
}


