import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
import 'package:kamilnotes/constants/routes.dart';
import 'package:kamilnotes/services/auth/auth_exceptions.dart';
import 'package:kamilnotes/services/auth/auth_services.dart';
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
              border: OutlineInputBorder(),
              labelText: 'password',
                hintText: 'password', prefixIcon: Icon(Icons.password)),
          ),
          const SizedBox(),
          TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                try {
                  //allows you to create a user with email and password in firebase
                  final userCredential = await AuthService.firebase()
                      .createUser(email: email, password: password);
                  devtools.log('The user Credential is $userCredential');
                  final user = AuthService.firebase().currentUser;
                  await AuthService.firebase().sendEmailVerification();
                } on WeakPasswordAuthException{
                    await showErrorDialog(context, 'wweak password');
                }on EmailAlreadyInUseAuthException{
                    await showErrorDialog(context, 'email already in use');
                }on InvalidEmailAuthException{
                    await showErrorDialog(context, 'invalid email entered');
                }on GenericAuthException{
                    await showErrorDialog(context, 'Error: Authentication Error');
                }catch (error) {
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
