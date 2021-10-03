import 'dart:async';
import 'dart:io' as io;
import 'package:path/path.dart';
import 'package:sms_flutter/Constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'User.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "mobileList.db");
    print("$path ____________________________________________________________________________________________________________________" );
    var theDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return theDb;
  }

  void _onCreate(Database db, int version) async {
    // When creating the db, create the table
    await db.execute(
        "CREATE TABLE NumberList(id INTEGER PRIMARY KEY AUTOINCREMENT,mobileno TEXT UNIQUE, status TEXT)");
    print("Created tables______________________numberlist___________________________________________________________________________________");

    await db.execute(
        "CREATE TABLE ValueStored(id INTEGER PRIMARY KEY AUTOINCREMENT,key TEXT UNIQUE, value TEXT)");
    print("Created tables______________________valueStored___________________________________________________________________________________");


  }

  void saveNumber(User user) async {
    var dbClient = await db;
    // print("_________${user.userMobile}___________________________");
    await dbClient.transaction((txn) async {
      return await txn.rawInsert(
          'INSERT OR IGNORE INTO NumberList(mobileno, status ) VALUES("${user.userMobile}", "${user.userMsgStatus}") ');
    });
  }

  void setValue(String key, String value) async {
    var dbClient = await db;
    // print("_________${user.userMobile}___________________________");
    await dbClient.transaction((txn) async {
      return await txn.rawInsert(
          'INSERT INTO ValueStored(key, value ) VALUES("${key}", "${value}") ON CONFLICT(key) DO UPDATE SET value = "${value}" ');
    });
  }

  void updateValue(String key, String value) async {
    var dbClient = await db;
    // print("_________${user.userMobile}___________________________");
    await dbClient.transaction((txn) async {
      return await txn.rawInsert(
          'UPDATE ValueStored SET value = "${value}" WHERE key = "${key}"');
    });
  }

  void updateNumber(User user) async {
    var dbClient = await db;
    
    await dbClient.transaction((txn) async {
      return await txn.rawUpdate('UPDATE NumberList SET status = "${user.userMsgStatus}" WHERE mobileno = "${user.userMobile}"');
    });
  }

  Future<List<String>> selectNumber() async {
    var dbClient = await db;
    var listNumber = await dbClient.rawQuery('SELECT mobileno FROM NumberList WHERE status= "${Constants.MSG_SENDING}" or status= "${Constants.MSG_INTIAL}" LIMIT 50 ');
// print(listNumber);

    List<String> mobNum = [];
    listNumber.forEach((dynamic row) => mobNum.add(row["mobileno"]));

    print(mobNum);
    return mobNum;


  }


  Future<String> getNumberStatus(String mobile) async {
    var dbClient = await db;
    var NumberStatus = await dbClient.rawQuery('SELECT status FROM NumberList WHERE mobileno= "$mobile" ');
// print(listNumber);



    // print("${NumberStatus[0]["status"]} ______________________________________________________________________________________________________");
    return NumberStatus[0]["status"].toString();


  }


  Future<String> getvalue(String key) async {
    var dbClient = await db;
    var NumberStatus = await dbClient.rawQuery('SELECT value FROM ValueStored WHERE key= "$key" ');
// print(listNumber);



    // print("${NumberStatus[0]["status"]} ______________________________________________________________________________________________________");
    return NumberStatus[0]["value"].toString();


  }
  
  
  // Future<List<User>> getUserMobileList() async {
  //   var dbClient = await db;
  //   List<Map> list = await dbClient.rawQuery('SELECT * FROM Employee');
  //   List<User> employees = new List();
  //   for (int i = 0; i < list.length; i++) {
  //     employees.add(new User(list[i]["firstname"], list[i]["lastname"], list[i]["mobileno"], list[i]["emailid"]));
  //   }
  //   print(employees.length);
  //   return employees;
  // }
}