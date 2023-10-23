import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {
  static String userLoggedInKey = "LOGGEDINKEY";
  static String userNameKey = "USERNAMEKEY";
  static String userEmailKey = "USEREMAILKEY";
  static String profilePicKey = "USERPROFILEPICKEY";
  static String userUIDKey = "USERUIDKEY";
  static String excursionIdKey = "EXCURSIONIDKEY";
  static String activeStreamingRoom = "ROOMIDKEY";

  static Future<bool> saveUserLoggedInStatus(bool isUserLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setBool(userLoggedInKey, isUserLoggedIn);
  }

  static Future<bool> saveUserUID(String userUID) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(userUIDKey, userUID);
  }

  static Future<bool> saveUserName(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(userNameKey, userName);
  }

  static Future<bool> saveUserEmail(String userEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(userEmailKey, userEmail);
  }

  static Future<bool> saveUserProfilePic(String profilePic) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(profilePicKey, profilePic);
  }

  static Future<bool> saveExcursionSession(String excursionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(excursionIdKey, excursionId);
  }

  static Future<String?> getExcursionSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(excursionIdKey);
  }

  static Future<bool> deleteExcursionSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.remove(excursionIdKey);
  }

  static Future<bool?> getUserLoggedInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(userLoggedInKey);
  }

  static Future<String?> getUserUID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userUIDKey);
  }

  static Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userNameKey);
  }

  static Future<String?> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey);
  }

  static Future<String?> getUserProfilePic() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(profilePicKey);
  }

  static Future<bool> clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }

  static Future<bool> setActiveStreamingRoom(String roomId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.setString(activeStreamingRoom, roomId);
  }

  static Future<String?> getActiveStreamingRoom() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(activeStreamingRoom);
  }

  static Future<bool> deleteActiveStreamingRoom() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await prefs.remove(activeStreamingRoom);
  }
}
