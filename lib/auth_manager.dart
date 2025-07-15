import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static const String _pinKey = 'pin';
  static const String _securityQuestionKey = 'securityQuestion';
  static const String _securityAnswerKey = 'securityAnswer';
  static const String _userProfileKey = 'userProfile';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<void> setPin(String pin) async {
    final prefs = await _prefs;
    await prefs.setString(_pinKey, pin);
  }

  Future<String?> getPin() async {
    final prefs = await _prefs;
    return prefs.getString(_pinKey);
  }

  Future<bool> verifyPin(String pin) async {
    final savedPin = await getPin();
    return savedPin == pin;
  }

  Future<void> setSecurityQuestion(String question, String answer) async {
    final prefs = await _prefs;
    await prefs.setString(_securityQuestionKey, question);
    await prefs.setString(_securityAnswerKey, answer);
  }

  Future<Map<String, String>?> getSecurityQuestion() async {
    final prefs = await _prefs;
    final question = prefs.getString(_securityQuestionKey);
    final answer = prefs.getString(_securityAnswerKey);
    if (question != null && answer != null) {
      return {'question': question, 'answer': answer};
    }
    return null;
  }

  Future<void> saveUserProfile(String profileName) async {
    final prefs = await _prefs;
    await prefs.setString(_userProfileKey, profileName);
  }

  Future<String?> loadUserProfile() async {
    final prefs = await _prefs;
    return prefs.getString(_userProfileKey);
  }

  Future<List<String>> getAllUserProfiles() async {
    final prefs = await _prefs;
    final keys = prefs.getKeys();
    final profileKeys = keys.where((key) => key.startsWith('userProfile_')).toList();
    return profileKeys.map((key) => key.substring(12)).toList();
  }

  Future<void> deleteUserProfile(String profileName) async {
    final prefs = await _prefs;
    await prefs.remove('userProfile_$profileName');
  }

  Future<void> switchUserProfile(String profileName) async {
    await saveUserProfile(profileName);
  }
}
