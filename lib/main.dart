import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sms_flutter/Constants.dart';
import 'package:sms_flutter/User.dart';
import 'package:sms_flutter/dbHelper.dart';
import 'package:telephony/telephony.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

class _MyHomePageState extends State<MyHomePage>  {
  // _MyHomePageState(this._permission);
  List<String> phones = [];
  List<String> messageNumber = [];
  bool isLoading = true;
  // final Permission _permission;
  // PermissionStatus _permissionStatus = PermissionStatus.denied;
  var dbHelper = DBHelper();
  bool isButtonClickable = true;
  @override
  void initState() {

    dbHelper.db;

    requestPermission();
    super.initState();
    setButtonStatus();


  }

  // final Telephony telephony = Telephony.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea (
        child: Scaffold(
          body: Stack(
            children: [
            WebView(
            initialUrl: "https://buyindia.net",
            javascriptMode: JavascriptMode.unrestricted,
            onPageFinished: (finish) {
              setState(() {
                isLoading = false;
              });
            },
            ),
              isLoading ? Center( child: CircularProgressIndicator(),)
                  : Stack(),
            ],
          ),
          floatingActionButton: isButtonClickable ? FloatingActionButton(

            onPressed: () {
              // if(isButtonClickable){
                sendMessageToMultiple();
                setState(() {
                  final now = DateTime.now();
                  final tomorrow = DateTime(now.year, now.month, now.day + 1);
                  isButtonClickable = false;
                  dbHelper.setValue(Constants.EXPIRE_TIME, tomorrow.toString());
                });
              // }
              // else {
              //   print("Button is disable________________________________________________________________");
              // }
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ) : FloatingActionButton(
              child: Icon(Icons.clear),
              onPressed: () {}),
        ),
      ),
    );
  }



  void setButtonStatus() async {
var expireTime = await dbHelper.getvalue(Constants.EXPIRE_TIME);
print("your expire timr is $expireTime");
final now = DateTime.now();

    if(expireTime != "") {
      final difference = now.difference(DateTime.parse(expireTime)).inSeconds;
      if(difference < 0){
        setState(() {
          isButtonClickable = false;
        });
      }

    }

  }

  void requestPermission() async {

    await Permission.sms.request();

    if(await Permission.contacts.request().isGranted){
      fetchContacts();
    }
    else {
      SystemNavigator.pop();
    }
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
        // print(phone.value.toString().replaceAll(" ", ""));

      });
    });

    // phones.toSet().toList();
    print(phones.length);
    messageNumber = importNumber(phones);
    messageNumber.forEach((element) {
      User user = User();
      user.userMobile = element;
      user.userMsgStatus = Constants.MSG_INTIAL;
      dbHelper.saveNumber(user);
    });
    // setList(PrefHelper.USER_MOBILE_LIST, messageNumber);
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

void sendMessage(String number,String message) async {
  final Telephony telephony = Telephony.instance;
  final SmsSendStatusListener listener = (SendStatus status) {
    String statusMsg = status.toString();
    print("${statusMsg} and number is $number ______________________________________________________________________");
    // User user = User();
    // user.userMobile = number;
    // user.userMsgStatus = status as String;
    // dbHelper.updateNumber(user);

  };

        telephony.sendSms(
          to: number,
          message: message,
          statusListener: listener
        );
  }

void sendMessageToMultiple() async {

List<String> numbers = await dbHelper.selectNumber() as List<String>;

// List<String> numbers = ["9427317742","8866050023","9714595540"];

print(numbers);
if(await Permission.sms.request().isGranted){
      numbers.forEach((element) async {
        if (await dbHelper.getNumberStatus(element) != Constants.MSG_DELIVERD) {
          sendMessage(element, Constants.Message);
          User user = User();
          user.userMobile = element;
          user.userMsgStatus = Constants.MSG_DELIVERD;
          dbHelper.updateNumber(user);
        }
      });
    } else {
  SystemNavigator.pop();
    }
  }
}
