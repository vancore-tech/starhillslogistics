import 'package:get_storage/get_storage.dart';

final box = GetStorage();

void saveToken(String token) {
  box.write('token', token);
}

void saveUserId(String userId) {
  box.write('userId', userId);
}

String getUserId() {
  return box.read('userId') ?? '';
}

String getToken() {
  return box.read('token') ?? '';
}

void saveOnboardingStatus(bool status) {
  box.write('onboarding', status);
}

bool getOnboardingStatus() {
  return box.read('onboarding') ?? false;
}

clearToken() {
  box.remove('token');
}
