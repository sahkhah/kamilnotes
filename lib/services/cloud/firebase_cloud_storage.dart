import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kamilnotes/services/cloud/cloud_note.dart';
import 'package:kamilnotes/services/cloud/cloud_storage_constants.dart';
import 'package:kamilnotes/services/cloud/cloud_storage_exceptions.dart';

class FirebaseCloudStorage {
  final notes = FirebaseFirestore.instance.collection('notes');   //get our notes from the firestore
  static final FirebaseCloudStorage _shared =
      FirebaseCloudStorage._sharedInstance();
  FirebaseCloudStorage._sharedInstance();
  factory FirebaseCloudStorage() => _shared;

  Future<void> deleteNote({required String documentId}) async {
    try {
      await notes.doc(documentId).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote(
      {required String documentId, required String text}) async {
    try {
      await notes.doc(documentId).update({textFieldName: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Stream<Iterable<CloudNote>> allNotes({required String ownerUserId}) {
    return notes.snapshots().map((event) => event.docs
        .map((doc) => CloudNote.fromSnapshot(doc))
        .where((note) => note.ownerUserId == ownerUserId));   //return all notes where the notesId is equal to owner userId
  }

  Future<Iterable<CloudNote>> getNote({required String ownerUserId}) async {    //get a single note
    try {
      return await notes
          .where(
            ownerUserIdFieldName,
            isEqualTo: ownerUserId,
          )
          .get()
          .then(
              (value) => value.docs.map((doc) => CloudNote.fromSnapshot(doc)));
    } catch (e) {
      throw CouldNotGetAllNoteException();
    }
  }

  Future<CloudNote> createNewNote({required String ownerUserId}) async {
    final document =
        await notes.add({ownerUserIdFieldName: ownerUserId, textFieldName: ''});
    final fetchedDocument = await document.get();
    return CloudNote(
        documentId: fetchedDocument.id, ownerUserId: ownerUserId, text: '');
  }
}
