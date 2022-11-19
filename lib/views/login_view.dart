import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kamilnotes/constants/routes.dart';
import 'package:kamilnotes/utilities/show_error_dialog.dart';
import '../firebase_options.dart';
import 'dart:developer' as devtools show log;

class LoginView extends StatefulWidget {
  const LoginView({
    super.key,
  });

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  // late Future _firebaseFuture;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                children: [
                  TextField(
                    controller: _email,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        hintText: 'email', prefixIcon: Icon(Icons.email)),
                  ),
                  const SizedBox(),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                        hintText: 'password', prefixIcon: Icon(Icons.password)),
                  ),
                  const SizedBox(),
                  TextButton(
                    onPressed: () async {
                      final email = _email.text;
                      final password = _password.text;
                      try {
                        //allows you to create a user with email and password in firebase
                        final userCredential = await FirebaseAuth.instance
                            .signInWithEmailAndPassword(
                                email: email, password: password);
                        devtools.log('The user Credential is $userCredential');
                        //a call back for when the user is signed in
                        FirebaseAuth.instance
                            .authStateChanges()
                            .listen((User? user) {
                          if (user == null) {
                            devtools.log('User is currently signed out');
                          } else {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                noteRoute, (route) => false);
                            devtools.log('User is signed in');
                          }
                        });
                      } on FirebaseAuthException catch (error) {
                        switch (error.code) {
                          case 'user-not-found':
                            await showErrorDialog(context, 'user not found');
                            break;
                          case 'wrong-password':
                            await showErrorDialog(context,
                                'password is incorrect, please try again');
                            break;
                          default:
                            await showErrorDialog(
                                context, 'Error: ${error.code}');
                        }

                        devtools.log(error.message.toString());
                        //catch an error that's not firebase auth
                      } catch (error) {
                        await showErrorDialog(context, 'Error: ${error.toString()}');
                      }
                    },
                    child: const Text('Login'),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            registerRoute, (route) => false);
                      },
                      child: const Text('Not Registered yet? Register Here!'))
                ],
              );
            } else if (snapshot.hasError) {
              return const Text('Error');
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
