const String tableCars = 'cars'; // name of table in database.
const String columnId = 'id'; // name of column in database to store car id.
const String columnPrice =
    'price'; // name of column in database to store price.
const String columnName = 'name'; // name of column in database to store name.
const String columnColor =
    'color'; // name of column in database to store color.
const String columnStatus =
    'status'; // name of column in database to store status.

class Cars {
  int?
      id; // nullable because it might not be set when a new car object (AUTOINCREMENT)
  String price;
  String name;
  String color;
  String? status;

  Cars({
    this.id,
    required this.price,
    required this.name,
    required this.color,
    this.status,
  });

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnPrice: price,
      columnName: name,
      columnColor: color,
      columnStatus: status,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Cars.fromMap(Map<String, Object?> map)
      : id = map[columnId] as int?,
        price = map[columnPrice] as String,
        name = map[columnName] as String,
        color = map[columnColor] as String,
        status = map[columnStatus] as String?;

  @override
  String toString() {
    return 'Cars{id: $id, price: $price, name: $name, color: $color, status: $status}';
  }
}
