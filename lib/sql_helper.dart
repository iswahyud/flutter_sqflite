import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE flutter_artikel(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        judul TEXT,
        deskripsi TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'artikel_global.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  static Future<int> simpanData(String judul, String? deskripsi) async {
    final db = await SQLHelper.db();

    final data = {'judul': judul, 'deskripsi': deskripsi};
    final id = await db.insert('flutter_artikel', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  static Future<List<Map<String, dynamic>>> getAllData() async {
    final db = await SQLHelper.db();
    return db.query('flutter_artikel', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('flutter_artikel', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateData(
      int id, String judul, String? deskripsi) async {
    final db = await SQLHelper.db();

    final data = {
      'judul': judul,
      'deskripsi': deskripsi,
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update('flutter_artikel', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  static Future<void> hapusData(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("flutter_artikel", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Gagal menghapus data: $err");
    }
  }
}