import 'package:flutter/material.dart';
import 'package:kamilnotes/services/auth/auth_services.dart';
import 'package:kamilnotes/services/cloud/cloud_note.dart';
import 'package:kamilnotes/services/cloud/firebase_cloud_storage.dart';
import 'package:kamilnotes/utilities/dialog/cannot_share_empty_note_dialog.dart';
import 'package:kamilnotes/utilities/generics/get_argument.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _noteService;
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    _noteService = FirebaseCloudStorage();
    _textEditingController = TextEditingController();
    super.initState();
  }

  void setUpTextControllerListener() {
    _textEditingController.removeListener(textControllerListener);
    _textEditingController.addListener(textControllerListener);
  }

  void textControllerListener() async {
    final note = _note;
    final text = _textEditingController.text;
    if (note != null) {
      _noteService.updateNote(documentId: note.documentId, text: text);
    }
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async {
    final widgetNote =
        context.getArgument<CloudNote>(); //this returns an instance of new note
    if (widgetNote != null) {
      //if the note exists return the note for an update
      _note = widgetNote; //first update our real database note
      _textEditingController.text = widgetNote
          .text; //in order to hide the textview and show the note instead
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    final newNote = await _noteService.createNewNote(ownerUserId: userId);
    _note = newNote;
    return newNote;
  }

  void deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textEditingController.text.isEmpty && note != null) {
      _noteService.deleteNote(documentId: note.documentId);
    }
  }

  void saveNoteIfTextIsNotEmpty() async {
    final note = _note;
    final text = _textEditingController.text;
    if (note != null && text.isNotEmpty) {
      await _noteService.updateNote(documentId: note.documentId, text: text);
    }
  }

  //automatically save notes when the user exists the new note page
  @override
  void dispose() {
    deleteNoteIfTextIsEmpty();
    saveNoteIfTextIsNotEmpty();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New Note'),
          actions: [
            IconButton(
                onPressed: () async {
                  final text = _textEditingController.text;
                  if (_note == null || text.isEmpty) {
                    await showCannotShareEmptyNoteDialog(context);
                  } else {
                    //Share.share(text);      //get the plugin share_plus
                    Share.share(text);
                  }
                },
                icon: const Icon(Icons.share))
          ],
        ),
        body: FutureBuilder(
          future: createOrGetExistingNote(context),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                //_note = snapshot.data as DatabaseNote;
                setUpTextControllerListener();
                return TextField(
                  controller: _textEditingController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: 'Start typing your notes here',
                  ),
                );
              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}
