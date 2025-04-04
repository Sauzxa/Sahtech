# Nutritionist Profile Creation Flow

This document outlines the implementation of the nutritionist profile creation flow, following the Figma designs.

## Screens Implemented

1. **Location Screen** (Modified `nutritioniste5.dart`)
   - Allows the nutritionist to select their cabinet location on a map
   - Added a confirmation dialog to verify the selected location
   - Includes a "Confirm" button that proceeds to the phone verification process

2. **Phone Number Entry Screen** (`nutritioniste_phone.dart`)
   - Allows the user to enter their professional phone number
   - Includes a country code selector (defaulted to Algeria +213)
   - Validates the input before proceeding

3. **SMS Verification Screen** (`nutritioniste_sms_verification.dart`)
   - Displays a 4-digit OTP input field
   - Includes a countdown timer (3 minutes)
   - Offers a "Resend" option after the timer expires
   - Validates the 4-digit code before proceeding

4. **Password Creation Screen** (`nutritioniste_password.dart`)
   - Allows setting up a secure password for the account
   - Includes password strength validation
   - Requires confirmation (password matching)
   - Includes show/hide password toggles for both fields

5. **Success Screen** (`nutritioniste_success.dart`)
   - Confirms successful profile creation
   - Displays a preview of the nutritionist profile card
   - Includes a button to navigate to the home screen

## Data Flow

1. User data is collected and passed through each screen using the `NutritionisteModel` class
2. Each screen adds its specific data to the model:
   - Location screen: adds latitude, longitude, and cabinet address
   - Phone screen: adds phone number
   - Password screen: adds password for authentication

## Model Updates

The `NutritionisteModel` class was updated to include:
- `password` field for storing the authentication password

## UI Features

All screens follow the Figma design specifications with:
- Consistent color scheme using AppColors.lightTeal as the primary color
- Responsive layout that adapts to different screen sizes
- Proper validation and error handling
- Multilingual support through the TranslationService
- Smooth navigation between screens

## Pending Work

- Integration with Firebase Authentication for actual phone verification
- Backend integration to save the nutritionist profile to Firestore
- Unit and integration tests to verify the flow works correctly

## How to Test

You can test the flow by:
1. Navigating to the nutritionist profile creation flow
2. Selecting a location on the map and confirming it
3. Entering a phone number
4. Entering any 4-digit code (currently mocked)
5. Creating a password (must meet requirements)
6. Viewing the success screen with profile details 