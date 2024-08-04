import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class FlightsDatabaseHelper {
  static final FlightsDatabaseHelper _instance = FlightsDatabaseHelper.internal();
  factory FlightsDatabaseHelper() => _instance;
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db!;
    }
    _db = await initDb();
    return _db!;
  }

  FlightsDatabaseHelper.internal();

  initDb() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'flights.db');

    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE Flights(id INTEGER PRIMARY KEY, departureCity TEXT, destinationCity TEXT, departureTime TEXT, arrivalTime TEXT)');
  }

  Future<int> saveFlight(Map<String, dynamic> flight) async {
    var dbClient = await db;
    int res = await dbClient.insert('Flights', flight);
    return res;
  }

  Future<List<Map<String, dynamic>>> getAllFlights() async {
    var dbClient = await db;
    var result = await dbClient.query('Flights', columns: ['id', 'departureCity', 'destinationCity', 'departureTime', 'arrivalTime']);
    return result.toList();
  }

  Future<int> updateFlight(Map<String, dynamic> flight) async {
    var dbClient = await db;
    return await dbClient.update('Flights', flight, where: 'id = ?', whereArgs: [flight['id']]);
  }

  Future<int> deleteFlight(int id) async {
    var dbClient = await db;
    return await dbClient.delete('Flights', where: 'id = ?', whereArgs: [id]);
  }
}
