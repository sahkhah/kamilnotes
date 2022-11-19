import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'dart:developer' as devtools show log;

import 'package:kamilnotes/constants/routes.dart';

import '../utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({
    super.key,
  });

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

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
      appBar: AppBar(title: const Text('Register')),
      body: Column(
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
                      .createUserWithEmailAndPassword(
                          email: email, password: password);
                          devtools.log('The user Credential is $userCredential');
                  final user = FirebaseAuth.instance.currentUser;
                  await user?.sendEmailVerification();
                  Navigator.of(context).pushNamed(verifyEmailRoute);
                  /* FirebaseAuth.instance.authStateChanges().listen((User? user) {
                    if (user == null) {
                      devtools.log('User is currently signed out');
                    } else {
                      //this makes the verify email rout lay ontop of the register route, incase the user press the back button
                     Navigator.of(context).pushNamed(
                      verifyEmailRoute);
                  devtools.log('The user Credential is $userCredential');
                    }
                  }); */
                } on FirebaseAuthException catch (error) {
                  if (error.code == 'weak-password') {
                    await showErrorDialog(context, 'wweak password');
                  } else if (error.code == 'email-already-in-use') {
                    await showErrorDialog(context, 'email already in use');
                  } else if (error.code == 'invalid-email') {
                    await showErrorDialog(context, 'invalid email entered');
                  } else {
                    await showErrorDialog(context, 'Error: ${error.code}');
                  }
                } catch (error) {
                  await showErrorDialog(context, 'Error: ${error.toString()}');
                }
              },
              child: const Text('Register')),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(loginRoute, (route) => false);
              },
              child: const Text('Already Registered? Login Here!'))
        ],
      ),
    );
  }
}
