import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as devtools show log;
import 'package:kamilnotes/constants/routes.dart';
import 'package:kamilnotes/services/auth/auth_services.dart';
import 'package:kamilnotes/services/auth/bloc/auth_event.dart';
import 'package:kamilnotes/services/cloud/cloud_note.dart';
import 'package:kamilnotes/services/cloud/firebase_cloud_storage.dart';
import 'package:kamilnotes/views/notes/note_listview.dart';
import '../../enums/menu_action.dart';
import '../../services/auth/bloc/auth_bloc.dart';
import '../../utilities/dialog/show_logout_dialog.dart';

class NoteView extends StatefulWidget {
  const NoteView({super.key});

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  //expose the current user's email
  String get userId => AuthService.firebase().currentUser!.id; //note
  late final FirebaseCloudStorage _noteService;

  @override
  void initState() {
    _noteService = FirebaseCloudStorage();
    super.initState();
  }

//any time we perform hot reload, the database closes, this is a bad practice,
/*   @override
  void dispose() {
    _noteService.closeDB();
    super.dispose();
  } */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('MAIN UI'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(createOrUpdateNoteRoute);
                },
                icon: const Icon(Icons.add)),
            PopupMenuButton<MenuAction>(
              onSelected: (value) async {
                switch (value) {
                  case MenuAction.logout:
                    final shouldLogout =
                        await showLogoutDialog(context, 'Logout');
                    if (shouldLogout) {
                      context.read<AuthBloc>().add(
                        const AuthEventLogOut()
                      );
                     // AuthService.firebase().signOut();
                    /*   Navigator.of(context)
                          .pushNamedAndRemoveUntil(loginRoute, (_) => false); */
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
        body: StreamBuilder(
                  stream: _noteService.allNotes(ownerUserId: userId),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState
                          .active: //this means that atleast one data is available
                        if (snapshot.hasData) {
                          final allNote = snapshot.data as Iterable<CloudNote>;
                          return NoteListView(
                            notes: allNote,
                            onDeleteNote: (note) async {
                              await _noteService.deleteNote( documentId: note.documentId);
                            },
                            onUpdateNote: (note) {
                              Navigator.of(context).pushNamed(
                                  createOrUpdateNoteRoute,
                                  arguments: note);
                            },
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      default:
                        return const CircularProgressIndicator();
                    }
                  },
                ));
  }
}
