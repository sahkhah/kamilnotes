import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerificationView extends StatefulWidget {
  const EmailVerificationView({super.key});
  @override
  State<EmailVerificationView> createState() => _EmailVerificationViewState();
}

class _EmailVerificationViewState extends State<EmailVerificationView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Your Email')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text('Please Verify Your Email'),
            const SizedBox(),
            TextButton(
                onPressed: () async {
                  try {
                    //get the current signed in user
                    final user = FirebaseAuth.instance.currentUser;
                    print(user?.toString());
                    //send email verification to the user
                    await user?.sendEmailVerification();
                  } on FirebaseAuthException catch (error) {
                    print(error.code);
                    print(error.message);
                  }
                },
                child: const Text('Verify Email')),
          ],
        ),
      ),
    );
  }
}
