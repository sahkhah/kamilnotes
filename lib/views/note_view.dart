import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

enum MenuAction { logout }

class NoteView extends StatefulWidget {
  const NoteView({super.key});

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MAIN UI'),
        actions: [
          IconButton(
            onPressed: (){}, 
            icon: const Icon(Icons.search)),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await _showLogoutDialog(context);
                  if (shouldLogout) {
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/login/', (_) => false);
                  }
                  //we have to say value.toString() bcos the log function only takes strings as argument
                  devtools.log(shouldLogout.toString());
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Logout'),
                )
              ];
            },
          ),
        ],
      ),
      body: const Text('Helo World'),
    );
  }
}

Future<bool> _showLogoutDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Logut'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Logout')),
        ],
      );
    },
    //if the user clicks outside the alert dialog instead of yes/no button we need to create a call back
  ).then((value) => value ?? false);
}
