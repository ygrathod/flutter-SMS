import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_flutter/Constants.dart';
import 'package:telephony/telephony.dart';
import 'package:contacts_service/contacts_service.dart';

import 'PrefHelper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with PrefHelper {
  // _MyHomePageState(this._permission);
  int _counter = 0;
  String statusNew = "";
  List<String> MoNuber = [];
  List<String> phones = [];
  List<String> messageNumber = [];
  // final Permission _permission;
  // PermissionStatus _permissionStatus = PermissionStatus.denied;
  @override
  void initState() {
    requestPermission();
    fetchContacts();
    super.initState();
  }


  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  final Telephony telephony = Telephony.instance;

  @override
  Widget build(BuildContext context) {
    final SmsSendStatusListener listener = (SendStatus status) {
      // Handle the status
      print(status);
      setState(() {
        statusNew = status.toString() ;
      });
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$statusNew',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          fetchContacts();

          // telephony.sendSms(
          //     to: "8758022838",
          //     message: "HI I am robot so may be this forced message!",
          //     statusListener: listener);


        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.sms,
      Permission.contacts,
    ].request();

    setState(() {
      print(statuses);
    });
  }

Future<void> fetchContacts() async {
  if (await Permission.contacts.request().isGranted) {
    // Either the permission was already granted before or the user just granted it.
    Iterable<Contact> contacts = await ContactsService.getContacts(withThumbnails: false);
    List<String?> names = [];

    print(contacts.length);
    contacts.forEach((contact) {
      contact.phones!.toSet().forEach((phone) {
        names.add(contact.displayName ?? contact.givenName);

        phones.add(phone.value.toString().replaceAll(" ", ""));
        print(phone.value.toString().replaceAll(" ", ""));

      });
    });


    // phones.toSet().toList();
    print(phones.length);
    messageNumber = importNumber(phones);
    setList(PrefHelper.USER_MOBILE_LIST, messageNumber);
  }
  else {
    requestPermission();
  }

  // debugPrint(phones.toString());
}

List<String> importNumber(List<String> phoneNumber) {

    List<String> realNumber = [];

    phoneNumber.forEach((element) {
      if(element.toString().length == 10) {
        realNumber.add(element);
        // print(element);
      } else if(element.toString().length == 13) {
        realNumber.add(element.toString().substring(3));
        // print(element.toString().substring(3));
      }
    });

    return (realNumber.toSet().toList());
    // return realNumber;
  }

Future<String> sendMessage(String number,String message) async {

  String statusStr = "";
  final SmsSendStatusListener listener = (SendStatus status) {
    statusStr = status as String;
  };

  if (await Permission.contacts.request().isGranted) {
      final Telephony telephony = Telephony.instance;

      if (number.length == 10) {
        telephony.sendSms(
          to: number,
          message: message,
          statusListener: listener
        );
      }
    }
  return statusStr;
  }

Future<void> sendMessageToMultiple(List<String?> numbers) async {

List<String>? diliverdContacts = getList(Constants.MSG_DELIVERD);

String statusOfMsg = "";




     for(var i = 0; i < numbers.length; i++) {


      }


    // if(numbers.length < 100) {
    //   numbers.forEach((element) {
    //     sendMessage(element!, "Hey this is just test Message. please don't irritate...");
    //   });
    // }
    // else if(numbers.length >= 100) {
    //
    // }


// if(statusOfMsg == "") {
//   if(!(diliverdContacts!.contains(element))){
//     statusOfMsg =  sendMessage(element!, Constants.Message) as String;
//     diliverdContacts.add(element);
//   }
//
// }else if (statusOfMsg == Constants.MSG_DELIVERD) {
//   if(!(diliverdContacts!.contains(element))){
//     statusOfMsg =  sendMessage(element!, Constants.Message) as String;
//     diliverdContacts.add(element);
//   }
// } else if (statusOfMsg == Constants.MSG_SENDING) {
//
// }
//
//
// if(!(diliverdContacts!.contains(element))){
//   sendMessage(element!, Constants.Message);
//   diliverdContacts.add(element);
// }


  }


}
