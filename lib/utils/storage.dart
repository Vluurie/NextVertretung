import 'package:shared_preferences/shared_preferences.dart';

class StorageItems {
  Future<String?> getClassBlockFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    String? className = prefs.getString('selectedBlock');
    return className;
  }

  Future<String?> getClassNameFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    String? className = prefs.getString('className');
    return className;
  }

  Future<bool?> getNotificationBool() async {
    final prefs = await SharedPreferences.getInstance();
    bool? isNotificationEnabled = prefs.getBool('isNotificationEnabled');
    return isNotificationEnabled;
  }

  Future<Future<bool>> deleteClassBlockFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    Future<bool> className = prefs.remove('selectedBlock');
    return className;
  }

  Future<Future<bool>> deleteClassNameFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    Future<bool> className = prefs.remove('selectedName');
    return className;
  }

  Future<bool?> deleteNotificationBool() async {
    final prefs = await SharedPreferences.getInstance();
    Future<bool> isNotificationEnabled = prefs.remove('isNotificationEnabled');
    return isNotificationEnabled;
  }
}
