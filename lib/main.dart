import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_flutter/UserContact.dart';
import 'package:telephony/telephony.dart';
import 'package:contacts_service/contacts_service.dart';

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

class _MyHomePageState extends State<MyHomePage> {
  // _MyHomePageState(this._permission);
  int _counter = 0;
  String statusNew = "";
  List<String> MoNuber = [];
  // final Permission _permission;
  // PermissionStatus _permissionStatus = PermissionStatus.denied;
  @override
  void initState() {
    requestPermission();

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
        statusNew = status.toString();
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
          sendMessage();
          // telephony.sendSms(
          //     to: "8758022838;9898649864;7573869262",
          //     message: "May the force be with you!",
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

Future<void> sendMessage() async {
  Iterable<Contact> contacts = await ContactsService.getContacts(withThumbnails: false);
  List<String?> names = [];
  List<String?> phones = [];
  contacts.forEach((contact) {
    contact.phones!.toSet().forEach((phone) {
      names.add(contact.displayName ?? contact.givenName);
      phones.add(phone.value);
      debugPrint(phone.toString());
    });
  });

  // debugPrint(phones.toString());



}


}
