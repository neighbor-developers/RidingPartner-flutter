import 'package:shared_preferences/shared_preferences.dart';
import '../models/record.dart';

class PreferenceUtils {
  static late SharedPreferences _prefs;

  static Future<SharedPreferences> init() async =>
      _prefs = await SharedPreferences.getInstance();

  static saveRecordPref(Record record) {
    setString("date", record.date!);
    setDouble("distance", record.distance!.toDouble());
    setInt("ridingTime", record.timestamp!.toInt());
  }

  static Record? getRecordFromPref() {
    double? distance = getDouble("distance");
    String? date = getString("date");
    int? time = getInt("ridingTime");

    if (distance == null) {
      return null;
    } else {
      return Record(
          distance: distance, date: date, timestamp: time, kcal: null);
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
