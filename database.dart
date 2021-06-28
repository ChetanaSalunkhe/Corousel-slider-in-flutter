import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteDbProvider {
  SQLiteDbProvider._();

  static final SQLiteDbProvider db = SQLiteDbProvider._();
  static Database _database;

  static String TABLE_NNAME = "Users";

  SQLiteDbProvider();

  Future<Database> get database async{
    if(_database != null){
      return database;
    }else{
      _database = await initDB();
      return database;
    }
}

initDB() async{

  if(_database != null){
    return database;
  }else{
    /*_database = await initDB();
    return database;*/
    var createTABLE = "CREATE TABLE "+TABLE_NNAME+" (ID INTEGER PRIMARY KEY AUTOINCREMENT, Name TEXT,"
        " Email TEXT, DOB TEXT, Address TEXT, Mobile TEXT, Password TEXT,Image TEXT)";

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'tinder.db');
    return await openDatabase(path, version: 1,onOpen: (db){},

        onCreate: (Database db, int version) async{
          await db.execute(createTABLE);

        });
  }
}

insertTODB(String name, String email, String dob, String address, String mobile, String password) async{
  int id1 = await _database.rawInsert(
      'INSERT INTO Users(Name, Email, DOB,Address,Mobile,Password) VALUES($name,$email,$dob,$address,$mobile,$password)');
  print('inserted1: $id1');
}

}