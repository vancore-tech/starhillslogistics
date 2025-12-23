class ApiConfig {
  static const String baseUrl =
      'https://starhills-logistcis-be-avbmfugsewgbcvg7.canadacentral-01.azurewebsites.net/api/v1/';

  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String verifyOtp = 'auth/verify-otp';
  static const String resendOtp = 'auth/resend-otp';
  static const String profileMe = 'users/me';
  static const String fetchCouriers = 'delivery/couriers';
  static const String fetchCategories = 'delivery/categories';
  static const String createDelivery = 'delivery/deliveries';
  static const String createRate = 'delivery/deliveries/rates';
  
  // Returns the full URL for creating a shipment
  static String createShipment(String deliveryId) =>
      '${baseUrl}delivery/deliveries/$deliveryId/shipments';

  // Google Places API Key - Replace with your actual API key
  static const String googlePlacesApiKey =
      'AIzaSyDTgt2XnPDLGyOj0Cu5HhmE0A9sO6WENOM';
}
