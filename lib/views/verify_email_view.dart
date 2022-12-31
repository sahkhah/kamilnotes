
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import 'package:kamilnotes/constants/routes.dart';
import 'package:kamilnotes/services/auth/auth_exceptions.dart';
import 'package:kamilnotes/services/auth/auth_services.dart';

import '../utilities/dialog/error_dialog.dart';


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
            const Text(
                'We\'ve sent you an email verification, please open your email to verify it '),
            const Text('Did not receive any mail? Click the button below'),
            const SizedBox(),
            TextButton(
                onPressed: () async {
                  try {
                    //get the current signed in user
                    final user = AuthService.firebase().currentUser;
                    devtools.log(user.toString());
                    //send email verification to the user
                    await AuthService.firebase().sendEmailVerification();
                  } on GenericAuthException{
                    await showErrorDialog(context, 'Failed to verify Email');
                  }
                  
                },
                child: const Text('Verify Email')),
            TextButton(
              onPressed: () async {
                await AuthService.firebase().signOut();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text('Restart'),
            ),
          ],
        ),
      ),
    );
  }
}
