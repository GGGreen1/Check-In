import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute('''CREATE TABLE courses(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      name TEXT,
      createAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    ''');

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

  static Future<sql.Database> db() async {
    return sql.openDatabase('database.db', version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  //////Courses

  static Future<int> createCourse(String name) async {
    final db = await SQLHelper.db();

    final data = {
      'name': name,
    };
    final id = await db.insert('courses', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getCourses() async {
    final db = await SQLHelper.db();
    return db.query('courses', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getCourse(int id) async {
    final db = await SQLHelper.db();
    return db.query('courses', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateCourse(int id, String name) async {
    final db = await SQLHelper.db();

    final data = {'name': name, 'createAt': DateTime.now().toString()};

    final result =
        await db.update('courses', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteCourse(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("courses", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong deleting an item: $err");
    }
  }

  //////Participants

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
    print('NFC ID HERE $nfcId');
    final id = await db.insert('participants', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getParticipants(
      int courseId) async {
    final db = await SQLHelper.db();
    return db.query('participants', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getParticipant(int id) async {
    final db = await SQLHelper.db();
    return db.query('participants', where: "id = ?", whereArgs: [id], limit: 1);
  }

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

  static Future<void> deleteParticipant(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("participants", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong deleting an item: $err");
    }
  }

  // List of Participants with same CourseId

  static Future<List<Map<String, dynamic>>> getParticipantsSameCourse(
      int courseId) async {
    final db = await SQLHelper.db();

    return db.rawQuery(
      'SELECT * FROM participants WHERE course_id = ?',
      [courseId],
    );
  }

  /*
  static Future<int> countParticipants(int courseId) async {
    final db = await SQLHelper.db();
    
    return db.rawQuery(
      'SELECT COUNT(*) AS number_of_participants_in_course FROM participants WHERE course_id = ?',
      [courseId],
    );
  }

  */

  // Status Methoden

  static Future<int> setPresent(int id, int present) async {
    final db = await SQLHelper.db();

    final data = {'present': present, 'createAt': DateTime.now().toString()};

    final result =
        await db.update('participants', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

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

  //NFC Methoden
  static Future<String> getNfcId(int id) async {
    final db = await SQLHelper.db();

    final List<Map<String, dynamic>> result = await db.query(
      'participants',
      columns: ['nfc_id'],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    print('RESULT of getNfcId${result.first['nfc_id']}');

    return result.first['nfc_id'];
  }
}
