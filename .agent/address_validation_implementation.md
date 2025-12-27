# Address Validation Implementation

## Overview
Implemented address validation functionality that validates both pickup and drop-off addresses when the user clicks "Continue" in the drop-off screen.

## Changes Made

### 1. API Configuration (`lib/const/api_config.dart`)
- Added new endpoint: `validateAddress = 'addresses/validate'`

### 2. Controller Updates (`lib/features/home/drop_off_controller.dart`)
- Added `pickupAddressCode` and `dropoffAddressCode` reactive variables to store validated address codes
- Implemented `validateAddress()` method that:
  - Takes an address string as input
  - Retrieves logged-in user data (name, email, phone) from storage
  - Sends POST request to `/addresses/validate` endpoint
  - Parses the nested response structure to extract `address_code`
  - Returns the address code on success, null on failure

### 3. UI Updates (`lib/features/home/drop_off_screen.dart`)
Updated the "Continue" button logic to:
1. Validate that both pickup and dropoff locations are selected
2. Show a non-dismissible loading dialog with message "Validating Addresses..."
3. Validate pickup address first
4. If pickup validation fails, close dialog and show error snackbar
5. Validate dropoff address
6. If dropoff validation fails, close dialog and show error snackbar
7. Store both address codes in the controller
8. Navigate to `ShipmentSenderReceiverScreen` with validated address codes

## API Integration

### Request Format
```json
{
  "name": "User Name",
  "email": "user@email.com",
  "phone": "08142403525",
  "address": "Selected address from Google Places"
}
```

### Response Format
```json
{
  "success": true,
  "result": {
    "success": true,
    "data": {
      "status": "success",
      "message": "Validation successful",
      "data": {
        "address_code": 987461306,
        "address": "Yaba, Oworonshoki, Nigeria",
        "formatted_address": "Yaba, Oworonshoki, Lagos, Nigeria",
        "country": "Nigeria",
        "city": "Surulere",
        "state": "Lagos",
        "latitude": 6.5095442,
        "longitude": 3.3710936
        // ... other fields
      }
    }
  }
}
```

## User Experience Flow
1. User selects pickup and drop-off locations
2. User clicks "Continue"
3. Loading dialog appears: "Validating Addresses..."
4. Both addresses are validated sequentially
5. On success: Dialog closes, navigation proceeds with address codes
6. On failure: Dialog closes, error message shown, user stays on screen

## Error Handling
- Missing locations: Shows snackbar asking user to select both locations
- Validation failure: Shows specific error for pickup or dropoff address
- Network errors: Caught and logged, returns null to trigger error flow
