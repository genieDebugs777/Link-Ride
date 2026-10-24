import 'package:shared_preferences/shared_preferences.dart';

class JourneyPreferencesService {
  static const String _priorityKey = 'journey_priority';
  static const String _gautrainKey = 'journey_mode_gautrain';
  static const String _metrorailKey = 'journey_mode_metrorail';
  static const String _busKey = 'journey_mode_bus';
  static const String _taxiKey = 'journey_mode_taxi';
  static const String _fewerTransfersKey = 'journey_prefer_fewer_transfers';

  Future<void> savePreferences({
    required String priority,
    required bool gautrainSelected,
    required bool metrorailSelected,
    required bool busSelected,
    required bool taxiSelected,
    required bool preferFewerTransfers,
  }) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    await preferences.setString(_priorityKey, priority);

    await preferences.setBool(_gautrainKey, gautrainSelected);

    await preferences.setBool(_metrorailKey, metrorailSelected);

    await preferences.setBool(_busKey, busSelected);

    await preferences.setBool(_taxiKey, taxiSelected);

    await preferences.setBool(_fewerTransfersKey, preferFewerTransfers);
  }

  Future<Map<String, dynamic>> getPreferences() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    return {
      'priority': preferences.getString(_priorityKey) ?? 'Balanced',
      'gautrainSelected': preferences.getBool(_gautrainKey) ?? true,
      'metrorailSelected': preferences.getBool(_metrorailKey) ?? true,
      'busSelected': preferences.getBool(_busKey) ?? true,
      'taxiSelected': preferences.getBool(_taxiKey) ?? true,
      'preferFewerTransfers': preferences.getBool(_fewerTransfersKey) ?? false,
    };
  }
}
