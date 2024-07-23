import 'package:sqflite/sqflite.dart';

import '../model/cars.dart';

class DataBase {
  var database;

  Future<void> initDatabase() async {
    database = await openDatabase(
      'myDataBase.db',
      version: 1,
      onCreate: (database, version) async {
        print('Database Created');
        await database
            .execute(
                "CREATE TABLE cars (id INTEGER PRIMARY KEY AUTOINCREMENT, price TEXT, name TEXT, color TEXT, status TEXT)")
            .then((value) {
          print("Table created");
        }).catchError((error) {
          print("Error when creating table: $error");
        });
      },
      onOpen: (database) {
        print('Database Opened');
      },
    ).catchError((error) {
      print("Error when opening database: $error");
    });
  }

  Future<void> insertToDataBase(Cars cars) async {
    await database.transaction((txn) async {
      int id1 = await txn.rawInsert(
          'INSERT INTO cars(price, name, color, status) VALUES(?, ?, ?, ?)',
          [cars.price, cars.name, cars.color, cars.status]);
      print('inserted1: $id1');
    });
  }

  Future<List<Map<String, dynamic>>> retrievedCard({String? status}) async {
    if (database != null) {
      String query = 'SELECT * FROM cars';
      if (status != null) {
        query += ' WHERE status = ?';
        return await database!.rawQuery(query, [status]);
      }
      return await database!.rawQuery(query);
    }
    return [];
  }

  Future<void> deleteCar(String carID) async {
    var car = await getCarByID(carID);
    if (car != null && car['status'] == 'saved') {
      await database?.rawDelete('DELETE FROM cars WHERE id = ?', [carID]);
    }
  }

  Future<Map<String, dynamic>?> getCarByID(String carID) async {
    List<Map<String, dynamic>> list =
        await database?.rawQuery('SELECT * FROM cars WHERE id = ?', [carID]);
    if (list.isNotEmpty) {
      return list.first;
    }
    return null;
  }

  Future<void> updateCar(Cars car) async {
    var existingCar = await getCarByID(car.id.toString());
    if (existingCar != null && existingCar['status'] == 'saved') {
      await database?.rawUpdate(
        'UPDATE cars SET price = ?, name = ?, color = ?, status = ? WHERE id = ?',
        [car.price, car.name, car.color, car.status, car.id],
      );
    }
  }

  Future<void> updateCarStatus(String carID, String status) async {
    var existingCar = await getCarByID(carID);
    if (existingCar != null && existingCar['status'] == 'saved') {
      await database?.rawUpdate(
        'UPDATE cars SET status = ? WHERE id = ?',
        [status, carID],
      );
    }
  }
}
