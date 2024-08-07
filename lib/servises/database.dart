import 'package:path/path.dart'; // for joining paths
import 'package:sqflite/sqflite.dart';

import '../model/cars.dart';

class DataBase {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'myDataBase.db'),
      version: 1,
      onCreate: (db, version) async {
        print('Database Created');
        await db
            .execute(
                "CREATE TABLE cars (id INTEGER PRIMARY KEY AUTOINCREMENT, price TEXT, name TEXT, color TEXT, status TEXT)")
            .then((value) {
          print("Table created");
        }).catchError((error) {
          print("Error when creating table: $error");
        });
      },
      onOpen: (db) {
        print('Database Opened');
      },
    ).catchError((error) {
      print("Error when opening database: $error");
    });
  }

  Future<void> insertToDataBase(Cars cars) async {
    final db = await database;
    await db.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO cars(price, name, color, status) VALUES(?, ?, ?, ?)',
          [cars.price, cars.name, cars.color, cars.status]);
      print('inserted1: $id1');
    });
  }

  Future<List<Map<String, dynamic>>> retrievedCard(
      {required String status, String? color}) async {
    final db = await database;

    final List<Map<String, dynamic>> maps;
    if (color != null) {
      maps = await db.query(
        'cars',
        where: 'status = ? AND color = ?',
        whereArgs: [status, color],
      );
    } else {
      maps = await db.query(
        'cars',
        where: 'status = ?',
        whereArgs: [status],
      );
    }

    return maps;
  }

  Future<void> deleteCar(String carID) async {
    final db = await database;
    var car = await getCarByID(carID);
    if (car != null && car['status'] == 'saved') {
      await db.rawDelete('DELETE FROM cars WHERE id = ?', [carID]);
    }
  }

  Future<Map<String, dynamic>?> getCarByID(String carID) async {
    final db = await database;
    List<Map<String, dynamic>> list =
        await db.rawQuery('SELECT * FROM cars WHERE id = ?', [carID]);
    if (list.isNotEmpty) {
      return list.first;
    }
    return null;
  }

  Future<void> updateCar(Cars car) async {
    final db = await database;
    var existingCar = await getCarByID(car.id.toString());
    if (existingCar != null && existingCar['status'] == 'saved') {
      await db.rawUpdate(
        'UPDATE cars SET price = ?, name = ?, color = ?, status = ? WHERE id = ?',
        [car.price, car.name, car.color, car.status, car.id],
      );
    }
  }

  Future<void> updateCarStatus(String carID, String status) async {
    final db = await database;
    var existingCar = await getCarByID(carID);
    if (existingCar != null && existingCar['status'] == 'saved') {
      await db.rawUpdate(
        'UPDATE cars SET status = ? WHERE id = ?',
        [status, carID],
      );
    }
  }
}
