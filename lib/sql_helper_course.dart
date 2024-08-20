/*
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SqlHelperCourse {
  static Future<void> createTables(sql.Database database) async {

    await database.execute("""CREATE TABLE categories(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      name TEXT,
      createAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    """);

  }

  static Future<sql.Database> db() async {
    return sql.openDatabase('courses.db', version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
    });
  }

  static Future<int> createItem(String name) async {
    final db = await SqlHelperCourse.db();

    final data = {'name': name};
    final id = await db.insert('categories', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getIems() async {
    final db = await SqlHelperCourse.db();
    return db.query('categories', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getIem(int id) async {
    final db = await SqlHelperCourse.db();
    return db.query('categories', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateItem(
      int id, String name) async {
    final db = await SqlHelperCourse.db();

    final data = {
      'name': name,
      'createAt': DateTime.now().toString()
    };

    final result =
        await db.update('categories', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> deleteItem(int id) async {
    final db = await SqlHelperCourse.db();
    try {
      await db.delete("categories", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong deleting an categorie: $err");
    }
  }
}
*/