/* import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; */
import 'package:flutter/material.dart';
import 'package:kamilnotes/views/login_view.dart';
import 'package:kamilnotes/views/note_view.dart';
import 'package:kamilnotes/views/register_view.dart';
/* import 'package:kamilnotes/views/verify_email_view.dart';
import 'firebase_options.dart';
 */

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
          '/login/': (context) => const LoginView(),
          '/register/': (context) => const RegisterView(),
        },
        home: FutureBuilder(
            future: Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                //get the current user
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  if (user.emailVerified) {
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
//git add -all
//git commit -m "initial commit"
//to push our code to git hub :1. add origin: git remote add origin + (copy the ssh from the github website)
//to push our code use git push -u origin HEAD -f (f means force push)
//git log
//git tag "Step-1"
//git push --tag
//git tag


