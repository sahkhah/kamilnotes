import 'package:flutter/material.dart';
import 'package:kamilnotes/services/cloud/cloud_note.dart';
import '../../utilities/dialog/show_delete_dialog.dart';

typedef NoteCallback = void Function(CloudNote note);

class NoteListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onUpdateNote;
  const NoteListView(
      {super.key, required this.notes, required this.onDeleteNote, required this.onUpdateNote});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        final note = notes.elementAt(index);  //when using Iterable usse this, an iterable is a lazy list
        return ListTile(
          onTap:() => onUpdateNote(note),
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ), //max lines shows a single line of the texts, textoverflow adds three dots
          trailing: IconButton(
              onPressed: () async {
                final shouldDelete = await showDeleteDialog(context, 'Delete');
                if (shouldDelete) {
                  onDeleteNote(note);
                }
              },
              icon: const Icon(Icons.delete)),
        );
      },
      itemCount: notes.length,
    );
  }
}
