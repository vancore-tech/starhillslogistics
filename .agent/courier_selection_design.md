# Shipment Courier Selection Screen - Design Documentation

## Overview
Redesigned the `ShipmentCourierSelectionScreen` to match the new API response structure with rich courier information including ratings, tracking levels, discounts, ETAs, and special highlights.

## API Response Structure

### Endpoint
`POST /rates/calculate`

### Response Format
```json
{
  "success": true,
  "data": {
    "status": "success",
    "message": "Retrieved successfully",
    "data": {
      "request_token": "...",
      "couriers": [...],
      "fastest_courier": {...},
      "cheapest_courier": {...},
      "checkout_data": {...}
    }
  }
}
```

### Courier Object Fields
Each courier in the `couriers` array contains:
- `courier_id`: Unique identifier
- `courier_name`: Display name
- `courier_image`: Logo URL
- `service_code`: Service identifier
- `insurance`: Insurance details (code, fee)
- `discount`: Discount information (percentage, symbol, discounted amount)
- `ratings`: Star rating (0-5)
- `votes`: Number of reviews
- `tracking_level`: Tracking quality (1-10)
- `tracking`: { bars: 1-5, label: "Excellent/Good/Average" }
- `rate_card_amount`: Original price
- `total`: Final price after discount
- `currency`: "NGN"
- `vat`: VAT amount
- `pickup_eta`: Pickup time estimate
- `delivery_eta`: Delivery time estimate
- `on_demand`: Boolean
- `waybill`: Boolean
- `is_cod_available`: Cash on delivery support

## UI Features

### 1. Filter Chips
Three filter options at the top:
- **All**: Shows all available couriers
- **Fastest**: Shows only the fastest courier
- **Cheapest**: Shows only the cheapest courier

Each chip displays the count of couriers in that category.

### 2. Courier Cards
Each courier is displayed in a card with:

#### Top Badges (when applicable)
- 🔥 **Fastest**: Orange badge for fastest delivery
- 💰 **Cheapest**: Green badge for lowest price
- 🎫 **Discount**: Red badge showing discount percentage

#### Main Content
- **Radio button**: Selection indicator
- **Courier logo**: 48x48 image with error fallback
- **Courier name**: Bold title
- **Star rating**: Visual stars + numeric rating + vote count
- **Price**: 
  - Strikethrough original price (if discounted)
  - Bold final price in primary color

#### Details Section
Three columns showing:
1. **Pickup**: Pickup ETA
2. **Delivery**: Delivery ETA
3. **Tracking**: Quality label with color coding

#### Tracking Quality Bar
Visual representation with 5 bars:
- Filled bars based on `tracking.bars` value
- Color coded:
  - Green: Excellent
  - Blue: Good
  - Orange: Average
  - Grey: Default

### 3. Selection State
- **Unselected**: White background, grey border
- **Selected**: 
  - Primary color border (2px)
  - Box shadow
  - Checked radio button

### 4. Bottom Action Bar
- **Back button**: Outlined button
- **Create Shipment button**: 
  - Primary color
  - Disabled until courier selected
  - Shows loading spinner during creation

## Color Coding

### Tracking Quality
- **Excellent**: Green (#4CAF50)
- **Good**: Blue (#2196F3)
- **Average**: Orange (#FF9800)
- **Default**: Grey

### Badges
- **Fastest**: Orange (#FF9800)
- **Cheapest**: Green (#4CAF50)
- **Discount**: Red (#F44336)

### Primary Theme
- **Main**: #3F4492 (Purple-blue)
- **Background**: #F8F9FA (Light grey)

## Loading States

### Initial Load
- Centered spinner
- "Finding best couriers for you..." message

### Creating Shipment
- Button disabled
- Spinner in button
- Prevents multiple submissions

## Error Handling

### No Couriers Found
- Shows snackbar: "No couriers found for the selected package details"
- Stays on previous screen

### API Error
- Shows snackbar with error message
- Clears courier list
- Allows retry by going back

## Controller Updates

### ShipmentController Changes
Updated `fetchRates()` method to parse nested response:
```dart
// New structure
data['data']['data']['couriers']

// Fallback for old structure
data['rates']
```

## User Experience Flow

1. User arrives from package details screen
2. Loading spinner shows while fetching rates
3. Filter chips appear with courier counts
4. Couriers displayed with all details
5. User can filter by fastest/cheapest
6. User selects a courier (card highlights)
7. User clicks "Create Shipment"
8. Loading spinner in button
9. Success message on completion

## Responsive Design

All measurements use ScreenUtil:
- `.w` for width
- `.h` for height
- `.sp` for font size
- `.r` for border radius

Ensures consistent appearance across device sizes.

## Accessibility Features

- Clear visual hierarchy
- High contrast text
- Touch-friendly tap targets (minimum 48x48)
- Loading indicators for async operations
- Error messages in snackbars
- Disabled state for unavailable actions
