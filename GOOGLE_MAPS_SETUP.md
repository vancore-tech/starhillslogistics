# Google Maps Setup Instructions

## IMPORTANT: Add Your Google Maps API Key

The app is now configured for Google Maps, but you **MUST** add your Google Maps API key to make it work.

### Step 1: Get Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable these APIs:
   - **Maps SDK for Android**
   - **Maps SDK for iOS**
   - **Places API**
4. Go to "Credentials" and create an API key
5. Restrict the API key (recommended):
   - For iOS: Restrict by iOS apps and add your bundle identifier
   - For Android: Restrict by Android apps and add your package name and SHA-1 certificate fingerprint

### Step 2: Add API Key to Your App

#### For iOS:
Open `ios/Runner/AppDelegate.swift` and replace:
```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY_HERE")
```
With your actual API key:
```swift
GMSServices.provideAPIKey("AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXX")
```

#### For Android:
Open `android/app/src/main/AndroidManifest.xml` and replace:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
```
With your actual API key:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXX"/>
```

#### For Google Places API:
Open `lib/const/api_config.dart` and replace:
```dart
static const String googlePlacesApiKey = 'YOUR_GOOGLE_PLACES_API_KEY_HERE';
```
With your actual API key:
```dart
static const String googlePlacesApiKey = 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
```

### Step 3: Clean and Rebuild

After adding your API keys:

#### For iOS:
```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

#### For Android:
```bash
flutter clean
flutter pub get
flutter run
```

## Configurations Added

### iOS Permissions (Info.plist)
- ✅ NSLocationWhenInUseUsageDescription
- ✅ NSLocationAlwaysAndWhenInUseUsageDescription
- ✅ io.flutter.embedded_views_preview

### Android Permissions (AndroidManifest.xml)
- ✅ INTERNET
- ✅ ACCESS_FINE_LOCATION
- ✅ ACCESS_COARSE_LOCATION

### iOS Configuration
- ✅ Google Maps imported in AppDelegate.swift
- ✅ GMSServices.provideAPIKey configured
- ✅ Minimum iOS version: 15.0

### Android Configuration
- ✅ Google Maps API key meta-data in AndroidManifest.xml

## Troubleshooting

### iOS App Crashes
- Make sure you've added the API key in `AppDelegate.swift`
- Run `cd ios && pod install` after any changes
- Check that location permissions are in Info.plist
- Ensure minimum iOS version is 15.0 or higher

### Android Issues
- Verify API key in AndroidManifest.xml
- Make sure all permissions are added
- Check that Maps SDK for Android is enabled in Google Cloud Console

### Map Shows Gray Screen
- API key is missing or invalid
- Required APIs are not enabled in Google Cloud Console
- API key restrictions are too strict (try unrestricted key for testing)

### Places Autocomplete Not Working
- Enable Places API in Google Cloud Console
- Verify the API key in `api_config.dart`
- Check internet connectivity

## Security Note

For production apps:
1. Never commit API keys to version control
2. Use environment variables or secure storage
3. Restrict API keys by platform (iOS/Android)
4. Set up billing alerts in Google Cloud Console
5. Monitor API usage regularly
