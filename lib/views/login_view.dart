import 'package:flutter/material.dart';
import 'package:kamilnotes/constants/routes.dart';
import 'package:kamilnotes/services/auth/auth_exceptions.dart';
import 'package:kamilnotes/services/auth/auth_services.dart';
import 'package:kamilnotes/utilities/show_error_dialog.dart';
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
          future: AuthService.firebase().initialize(),
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
                    onPressed: () async{
                      final email = _email.text;
                      final password = _password.text;
                      try{
                        //allows you to lgin a user with email and password in firebase
                        await AuthService.firebase()
                            .login(email: email, password: password);
                        //a call back for when the user is signed in
                        final user = AuthService.firebase().currentUser;
                            if (user?.isEmailVerified??false) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  noteRoute, (route) => false);
                              devtools.log('User is signed in');
                            } else {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  verifyEmailRoute, (route) => false);
                            }
                          }on UserNotFoundAuthException{
                              await showErrorDialog(context, 'user not found');
                          } on WeakPasswordAuthException{
                              await showErrorDialog(context,
                                'password is incorrect, please try again');
                          }on GenericAuthException{
                              await showErrorDialog(
                            context, 'Error: Authentication Error');
                          } catch (error) {
                            await showErrorDialog(
                            context, 'Error: ${error.toString()}');
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
