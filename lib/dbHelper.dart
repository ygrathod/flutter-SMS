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
    print("Created tables");

  }

  void saveNumber(User user) async {
    var dbClient = await db;
    // print("_________${user.userMobile}___________________________");
    await dbClient.transaction((txn) async {
      return await txn.rawInsert(
          'INSERT OR IGNORE INTO NumberList(mobileno, status ) VALUES("${user.userMobile}", "${user.userMsgStatus}") ');
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
    var listNumber = await dbClient.rawQuery('SELECT mobileno FROM NumberList WHERE status= "${Constants.MSG_SENDING}" or status= "${Constants.MSG_INTIAL}" ');
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