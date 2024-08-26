import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

// Verwalten der Datenbanken

class SQLHelper {
  // Datenbank für die Kurse wird festgelegt
  static Future<void> createTables(sql.Database database) async {
    await database.execute('''CREATE TABLE courses(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      name TEXT,
      createAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    ''');

    // Datenbank für Teilnehmer wird festgelegt
    await database.execute('''CREATE TABLE participants(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      prename TEXT,
      surname TEXT,
      matrikelnummer TEXT,
      nfc_id TEXT,
      course_id INTEGER,
      present INTEGER DEFAULT 0,
      createAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (course_id) REFERENCES courses (id) 
    )
    ''');
  }

  // Datenbanken werden erstellt
  static Future<sql.Database> db() async {
    return sql.openDatabase('database.db', version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  ////////////////////////
  // Methoden für Kurse //

  // Kurs erstellen
  static Future<int> createCourse(String name) async {
    // 'db' übernimmt Daten aus der Datenbank
    final db = await SQLHelper.db();

    // Zeile wird mit übergebenem Namen gefüllt
    final data = {
      'name': name,
    };
    final id = await db.insert('courses', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Daten aller Kurse werden abgerufen
  static Future<List<Map<String, dynamic>>> getCourses() async {
    final db = await SQLHelper.db();
    return db.query('courses', orderBy: "id");
  }

  // Daten eines bestimmten Kurses werden abgerufen
  static Future<List<Map<String, dynamic>>> getCourse(int id) async {
    final db = await SQLHelper.db();
    return db.query('courses', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Kurs wird aktualisiert
  static Future<int> updateCourse(int id, String name) async {
    final db = await SQLHelper.db();

    final data = {'name': name, 'createAt': DateTime.now().toString()};

    final result =
        await db.update('courses', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Kurs wird gelöscht
  static Future<void> deleteCourse(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("courses", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong deleting an item: $err");
    }
  }

  /////////////////////////////
  // Methoden für Teilnehmer //

  // Teilnehmer wird erstellt
  static Future<int> createParticipant(String prename, String surname,
      String matrikelnummer, String nfcId, int courseId, int present) async {
    final db = await SQLHelper.db();

    final data = {
      'prename': prename,
      'surname': surname,
      'matrikelnummer': matrikelnummer,
      'nfc_id': nfcId,
      'course_id': courseId,
      'present': present,
    };

    final id = await db.insert('participants', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Daten aller Teilnehmer werden abgerufen
  static Future<List<Map<String, dynamic>>> getParticipants(
      int courseId) async {
    final db = await SQLHelper.db();
    return db.query('participants', orderBy: "id");
  }

  // Daten eines bestimmten Teilnehmers werden abgerufen
  static Future<List<Map<String, dynamic>>> getParticipant(int id) async {
    final db = await SQLHelper.db();
    return db.query('participants', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Teilnehmer wird aktualisiert
  static Future<int> updateParticipant(
      int id, String prename, String surname, String matrikelnummer) async {
    final db = await SQLHelper.db();

    final data = {
      'prename': prename,
      'surname': surname,
      'matrikelnummer': matrikelnummer,
      'createAt': DateTime.now().toString()
    };

    final result =
        await db.update('participants', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Teilnehmer wird gelöscht
  static Future<void> deleteParticipant(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("participants", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong deleting an item: $err");
    }
  }

  // Liste von Teilnehmern, die den gleichen Kurs haben
  static Future<List<Map<String, dynamic>>> getParticipantsSameCourse(
      int courseId) async {
    final db = await SQLHelper.db();

    return db.rawQuery(
      'SELECT * FROM participants WHERE course_id = ?',
      [courseId],
    );
  }

  // Methode setzt die "Anwesenheit" / "Status" eine Teilnehmers fest
  static Future<int> setPresent(int id, int present) async {
    final db = await SQLHelper.db();

    final data = {'present': present, 'createAt': DateTime.now().toString()};

    final result =
        await db.update('participants', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // "Status" des Teilnehmers wird abgerufen und zurückgegeben
  static Future<int> getPresent(int id) async {
    final db = await SQLHelper.db();

    final List<Map<String, dynamic>> result = await db.query(
      'participants',
      columns: ['present'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return result.first['present'];
  }

  // Methode gibt die NFC-Id zurück
  static Future<String> getNfcId(int id) async {
    final db = await SQLHelper.db();

    final List<Map<String, dynamic>> result = await db.query(
      'participants',
      columns: ['nfc_id'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    return result.first['nfc_id'];
  }
}
