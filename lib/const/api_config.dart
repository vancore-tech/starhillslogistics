class ApiConfig {
  static const String baseUrl =
      'https://starhills-logistcis-be-avbmfugsewgbcvg7.canadacentral-01.azurewebsites.net/api/v1/';

  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String verifyOtp = 'auth/verify-otp';
  static const String resendOtp = 'auth/resend-otp';
  static const String profileMe = 'user/me';
  static const String fetchCouriers = 'delivery/couriers';

  // Google Places API Key - Replace with your actual API key
  static const String googlePlacesApiKey = '';
}
