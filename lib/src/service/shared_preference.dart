import 'package:shared_preferences/shared_preferences.dart';

import '../models/record.dart';

class PreferenceUtils {
  static late SharedPreferences _prefs;

  static Future<SharedPreferences> init() async =>
      _prefs = await SharedPreferences.getInstance();

  static saveRecordPref(Record record) {
    setString("date", record.date);
    setDouble("distance", record.distance.toDouble());
    setInt("timeStamp", record.timestamp.toInt());
    setDouble('topSpeed', record.topSpeed);
  }

  static saveRecordMemoPref(Record record) {
    setString("memo", record.memo!);
  }

  static Record? getRecordFromPref() {
    double? distance = getDouble("distance");
    String? date = getString("date");
    int? time = getInt("timeStamp");
    double? topSpeed = getDouble('topSpeed');
    String? memo = getString("memo");

    if (distance == null) {
      return null;
    } else {
      return Record(
          distance: distance,
          date: date!,
          timestamp: time!,
          topSpeed: topSpeed!,
          memo: memo);
    }
  }

  static Future<bool> setBool(String key, bool value) async =>
      await _prefs.setBool(key, value);

  static Future<bool> setDouble(String key, double value) async =>
      await _prefs.setDouble(key, value);

  static Future<bool> setInt(String key, int value) async =>
      await _prefs.setInt(key, value);

  static Future<bool> setString(String key, String value) async =>
      await _prefs.setString(key, value);

  static Future<bool> setStringList(String key, List<String> value) async =>
      await _prefs.setStringList(key, value);

  //gets
  static bool? getBool(String key) => _prefs.getBool(key);

  static double? getDouble(String key) => _prefs.getDouble(key);

  static int? getInt(String key) => _prefs.getInt(key);

  static String? getString(String key) => _prefs.getString(key);

  static List<String>? getStringList(String key) => _prefs.getStringList(key);

  //deletes..
  static Future<bool> remove(String key) async => await _prefs.remove(key);

  static Future<bool> clear() async => await _prefs.clear();
}
