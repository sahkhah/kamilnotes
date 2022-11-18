import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:kamilnotes/views/login_view.dart';
import '../firebase_options.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key,});
 
  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late Future _firebaseFuture;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    _firebaseFuture = Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
              hintText: 'password',
              prefixIcon: Icon(Icons.password)),
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
                print('The user Credential is $userCredential');
              } on FirebaseAuthException catch (error) {
                print(error.message);
              }
            },
            child: const Text('Register')),
        TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login/', (route) => false);
              },
              child: const Text('Already Registered? Login Here!'))
      ],
     ),
   );
  }
}
