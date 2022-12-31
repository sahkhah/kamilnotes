/* import 'dart:async';

import 'package:kamilnotes/extensions/lib/filter.dart';
import 'package:kamilnotes/services/crud/crud_exceptions.dart';
import 'package:kamilnotes/services/auth/auth_exceptions.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseUser {
  final String email;
  final int id;

  const DatabaseUser({required this.email, required this.id});

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'person id is $id, and email is $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNote(
      {required this.id,
      required this.userId,
      required this.text,
      required this.isSyncedWithCloud});

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdcolumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note, ID = $id, userid = $userId, isSynced with cloud = $isSyncedWithCloud, text = ${text.substring(0, ((text.length) ~/ 4))}';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class NoteService {
  Database? _db;
  DatabaseUser? _user;

  //Making NoteService a singleton
  static final NoteService _shared = NoteService._sharedInstance();
  NoteService._sharedInstance() {
    _noteStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        _noteStreamController.sink.add(_notes);
      },
    );
  }

  factory NoteService() => _shared;

  List<DatabaseNote> _notes = [];
  //keeps the lists aware of any operation on the notes in the list , i.e update, delete and creation
  late final StreamController<List<DatabaseNote>> _noteStreamController;

  //get the stream of notes
  Stream<List<DatabaseNote>> get allNote =>
      _noteStreamController.stream.filter((note) {
        final currentUser = _user;
        if (currentUser != null) {
          return note.userId == currentUser.id;
        } else {
          throw UserShouldBeSetBeforeReadingAllNotes();
        }
      });

  Future<DatabaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    await _ensureDBIsOpen();
    try {
      final existingUser = await getUser(email: email);
      if (setAsCurrentUser) {
        _user = existingUser;
      }
      return existingUser;
    } on UserAlreadyExistException {
      //this is some mad stuff
      final newUser = await createUser(email: email);
      if (setAsCurrentUser) {
        _user = newUser;
      }
      return newUser;
    } catch (e) {
      rethrow; //useful for debugging...
    }
  }

  Future<void> _ensureDBIsOpen() async {
    try {
      await openDB();
    } on DatabaseAlreadyOpenedException {
      //let it slide
    }
  }

  Future<void> _cacheNotes() async {
    await _ensureDBIsOpen();
    final allNotes = await getAllNotes();
    //convert the iterable to list
    _notes = allNotes.toList();
    //update the controller
    _noteStreamController.add(_notes);
  }

  Future<DatabaseNote> updateNote(
      {required DatabaseNote note, required String text}) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    //check if the note exists
    await getNote(id: note.id);
    final updateCount = await db.update(
        noteTable, {textColumn: text, isSyncedWithCloudColumn: 0},
        where: 'id = ?', whereArgs: [note.id]);
    if (updateCount == 0) throw CouldNotUpdateNoteException;
    final updatedNote = await getNote(id: note.id);
    _notes.removeWhere((element) => element.id == note.id);
    _notes.add(updatedNote);
    _noteStreamController.add(_notes);
    return updatedNote;
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    final listOfNotes = await db.query(noteTable);
    if (listOfNotes.isEmpty) throw NoteDoNotExistException();
    //here we are converting from a list of map to a list of database
    final result = listOfNotes.map((e) => DatabaseNote.fromRow(e));
    return result;
  }

  Future<void> deleteNote({required int id}) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = db.delete(noteTable, where: 'id = ?', whereArgs: [id]);
    // ignore: unrelated_type_equality_checks
    if (deleteCount == 0) throw NoteCouldNotBeDeletedException();
    final countBefore = _notes.length;
    //remove an item in this note where the item id is equal to the argument id
    _notes.removeWhere((item) => item.id == id);
    if (_notes.length != countBefore) _noteStreamController.add(_notes);
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    //the database query returns a list of maps so to get a single map from the list we use limits
    final notes =
        await db.query(noteTable, where: 'id = ?', whereArgs: [id], limit: 1);

    if (notes.isEmpty) throw NoteDoNotExistException();
    final note = DatabaseNote.fromRow(notes.first);
    //the note been return might be outdated, so we have to renew our note list
    _notes.removeWhere((element) => element.id == id);
    _noteStreamController.add(_notes);
    return note;
  }

  Future<int> deleteAllNotes() async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    final noOfDeletions = await db.delete(noteTable);
    //empty the note
    _notes = [];
    //update the stream controller
    _noteStreamController.add(_notes);
    return noOfDeletions;
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    //check if the user exists
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) throw UserNotFoundException();

    const text = '';
    final noteId = await db.insert(noteTable, {
      userIdcolumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );

    _notes.add(note);
    _noteStreamController.add(_notes);
    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable,
        limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);
    //if the user has been created already before or the user already exists, throw exception
    if (results.isEmpty) throw UserNotFoundException();

    return DatabaseUser.fromRow(results.first);
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    final results = await db.query(userTable,
        limit: 1, where: 'email = ?', whereArgs: [email.toLowerCase()]);
    //if the user has been created already before or the user already exists, throw exception
    if (results.isNotEmpty) throw UserAlreadyExistException();

    final userId =
        await db.insert(userTable, {emailColumn: email.toLowerCase()});

    return DatabaseUser(email: email, id: userId);
  }

  Future<void> deleteDB({required String email}) async {
    await _ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(userTable,
        where: 'email = ?', whereArgs: [email.toLowerCase()]);
    if (deleteCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> openDB() async {
    if (_db != null) throw DatabaseAlreadyOpenedException();
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final databasePath = join(docsPath.path, dbName);

      final db = await openDatabase(databasePath);
      _db = db;

      //create user table
      await db.execute(createUserTable);

      //create note table
      await db.execute(createNoteTable);
      //after opening the database and creating the tables, get all notes
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectoryException();
    }
  }

  Future<void> closeDB() async {
    await _ensureDBIsOpen();
    final db = _db;
    if (db == null) throw DatabaseIsNotOpenException();
    db.close();
    _db = null;
  }
}

const dbName = 'notes.db';
const userTable = 'user';
const noteTable = 'note';
const idColumn = 'id';
const emailColumn = 'email';
const userIdcolumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'is_synced_with_cloud';
const createUserTable = '''CREATE TABLE IF NOT EXISTS "user"(
        "id" INTEGER NOT NULL,
        "email" TEXT NOT NULL UNIQUE,
        PRIMARY KEY ("id" AUTOINCREMENT)
      );''';
const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note"(
    "id" INTEGER NOT NULL,
    "user_id" INTEGER NOT NULL,
    "text" TEXT,
    "is_synced_with_cloud" INTEGER NOT NULL DEFAULT 0,
    "FOREIGN KEY("user_id") REFERENCES "user"("id"),
    PRIMARY KEY ("id" AUTOINCREMENT)
  );''';
 */