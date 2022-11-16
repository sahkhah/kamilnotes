import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'package:kamilnotes/views/register_view.dart';
//import 'package:kamilnotes/views/login_view.dart';

import 'firebase_options.dart';

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
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Homepage'),
            ),
            //initialize firebase before using it
            body: FutureBuilder(
                future: Firebase.initializeApp(
                  options: DefaultFirebaseOptions.currentPlatform,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    //get the current user
                    final user = FirebaseAuth.instance.currentUser;
                    print(user);
                    //check if the user email is verified
                    final emailVerified = user?.emailVerified ?? false;
                    if (emailVerified) {
                      print('Email is verified');
                    } else {
                      print('${user?.email} email is not verified');
                    }
                    /* if (user != null) {
                      if (user.emailVerified) {
                        print('Email is verified');
                      }
                    } */
                    return const Center(child: Text('DONE'));
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                })));
  }
}
