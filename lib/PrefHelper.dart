import 'package:shared_preferences/shared_preferences.dart';

class PrefHelper {
  SharedPreferences? pref;

  Future<void> init() async {
    pref = await SharedPreferences.getInstance();
  }

  static const USER_MOBILE_LIST = "userMobileList";
  static const USER_DELIVERD_MSG_LIST = "userMSGdiliverdMsg";

  Future<void> setList(String key, List<String> valuelist) async {
    await pref?.setStringList(key, valuelist);
  }

  List<String>? getList(String key, {List<String>? defaultValue}) {
    var result = pref?.getStringList(key);
    if (result == null && defaultValue != null) {
      return defaultValue;
    } else
       return result;
  }

  Future<bool> clear() async {
    return await pref!.clear();
  }
}
