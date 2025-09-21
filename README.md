# SAHTECH

## Overview
Sahtech is a comprehensive health and nutrition platform designed to help users make informed decisions about food products. The platform consists of multiple integrated components:

1. **Mobile Application** - A Flutter-based mobile app for users to scan food products, receive personalized recommendations, and manage their health profiles, contact nutritionists, chat with them, update their health status, and more enhanced features coming soon...
2. **Backend Server** - A Spring Boot server that handles user authentication, data storage, and business logic.
3. **AI Component** - An AI-powered recommendation system that analyzes food products based on user health profiles, built with agentic ReAct architecture using LangChain.
4. **Landing Page Website** - A descriptive website that showcases the platform's features and benefits.
5. **Collaboration Form** - A system for advertisers and partners to submit collaboration requests.
6. **Analytics Dashboard** - A dashboard to monitor user metrics, downloads, and platform performance.

![Sahtech Logo](https://github.com/yourusername/sahtech/raw/main/images/sahtech_logo.png)

## Platform Screenshots

### Mobile Application - Real App Screenshots
*Screenshots from the actual Android application*

#### Onboarding & Presentation
<div style="display: flex; flex-wrap: wrap; gap: 10px;">
  <img src="SahtechFront/lib/assets/ImagesForReadmeFile/Presentation.png" alt="App Presentation 1" width="200"/>
  <img src="SahtechFront/lib/assets/ImagesForReadmeFile/Presentation2.png" alt="App Presentation 2" width="200"/>
  <img src="SahtechFront/lib/assets/ImagesForReadmeFile/Presentation3.png" alt="App Presentation 3" width="200"/>
</div>

#### User Role Selection & Setup
<div style="display: flex; flex-wrap: wrap; gap: 10px;">
  <img src="SahtechFront/lib/assets/ImagesForReadmeFile/ChoiceUserRole.png" alt="User Role Selection" width="200"/>
  <img src="SahtechFront/lib/assets/ImagesForReadmeFile/Selectpage1.png" alt="User Selection Page 1" width="200"/>
  <img src="SahtechFront/lib/assets/ImagesForReadmeFile/Selectpage2.png" alt="User Selection Page 2" width="200"/>
  <img src="SahtechFront/lib/assets/ImagesForReadmeFile/SelectPage3.png" alt="User Selection Page 3" width="200"/>
</div>

#### Main Application Features
<div style="display: flex; flex-wrap: wrap; gap: 10px;">
  <img src="SahtechFront/lib/assets/ImagesForReadmeFile/HomeScreen.png" alt="Home Screen" width="200"/>
  <img src="SahtechFront/lib/assets/ImagesForReadmeFile/Scanne.png" alt="Scanning Interface" width="200"/>
  <img src="SahtechFront/lib/assets/ImagesForReadmeFile/ResultScann.png" alt="Scan Results" width="200"/>
  <img src="SahtechFront/lib/assets/ImagesForReadmeFile/HistoriqueScann.png" alt="Scan History" width="200"/>
  <img src="SahtechFront/lib/assets/ImagesForReadmeFile/SettingsProfile.png" alt="Profile Settings" width="200"/>
</div>

### Website
![Sahtech Website](https://github.com/yourusername/sahtech/raw/main/images/website_landing.png)

### Analytics Dashboard
![Sahtech Dashboard](https://github.com/yourusername/sahtech/raw/main/images/dashboard.png)

## Platform Components

### Mobile Application (SahtechFront)
- **Technology**: Flutter (cross-platform)
- **Architecture**: Clean Architecture with layered structure
- **State Management**: Provider pattern
- **Key Dependencies**:
  - **UI/UX**: Google Fonts, Font Awesome Flutter, Animated Text Kit, Flutter ScreenUtil
  - **Navigation & Routing**: Built-in Flutter navigation
  - **HTTP Networking**: HTTP package for API communication
  - **Storage**: Shared Preferences, Flutter Secure Storage
  - **Camera & Scanning**: Image Picker, QR Code Scanner, Mobile Scanner
  - **Maps & Location**: Google Maps Flutter, Geolocator, Geocoding
  - **Connectivity**: Connectivity Plus for network status
  - **WebView**: WebView Flutter for embedded web content
  - **Device Preview**: For responsive design testing

- **Project Structure**:
  ```
  lib/
  ├── core/                    # Core application logic
  │   ├── auth/               # Authentication logic
  │   ├── base/               # Base classes and interfaces
  │   ├── config/             # App configuration
  │   ├── CustomWidgets/      # Reusable custom widgets
  │   ├── l10n/               # Localization files
  │   ├── services/           # API services and business logic
  │   ├── theme/              # App theming and styling
  │   └── utils/              # Utility functions
  ├── presentation/           # UI layer
  │   ├── home/               # Home screen components
  │   ├── nutritionist/       # Nutritionist consultation features
  │   ├── onboarding/         # User onboarding screens
  │   ├── profile/            # User profile management
  │   ├── scan/               # Product scanning functionality
  │   └── widgets/            # Shared UI widgets
  ├── screens/                # Main application screens
  └── assets/                 # Images and static assets
  ```

- **Features**:
  - Cross-platform support (Android, iOS, Web, Windows, macOS)
  - Barcode and QR code scanning for food products
  - Personalized recommendations based on health profile
  - User profile management (allergies, chronic diseases, preferences)
  - Nutritionist contact and consultation
  - History of scanned products
  - Google Maps integration for location services
  - Secure local data storage
  - Responsive design with device preview support
  - Internationalization (i18n) support
  - Custom launcher icons for all platforms

### Backend Server
- **Technology**: Spring Boot (Java)
- **Features**:
  - RESTful API endpoints
  - MongoDB database integration
  - User authentication and authorization
  - Product data management
  - Health profile storage and analysis

### AI Component
- **Technology**: FastAPI (Python) with Groq LLM API integration
- **Features**:
  - Product analysis based on ingredients and nutritional content
  - Personalized recommendations considering user health profiles
  - Detection of potential allergens and health concerns
  - Nutritional advice generation

### Static Website
- **URL**: https://sahtech-website.vercel.app/
- **Features**:
  - Platform description and benefits
  - Download links for the mobile application
  - Information about the team and technology
  - Contact information and support

### Collaboration Form
- **Purpose**: Allows businesses to submit advertising requests
- **Features**:
  - Partner registration system
  - Ad submission and management
  - Billing and payment tracking

### Analytics Dashboard
- **Features**:
  - User metrics (total users, active users)
  - Download statistics
  - Product scan analytics
  - Partner and advertisement performance tracking

## System Architecture
The Sahtech platform follows a microservices architecture:
- **SahtechFront**: Flutter mobile application frontend
- **SahtechServer**: Spring Boot backend server
- **SahtechAI**: AI recommendation service with FastAPI

## Getting Started

### Prerequisites
- Flutter SDK (for mobile app development)
- Java JDK 11+ and Maven (for backend server)
- Python 3.8+ (for AI component)
- MongoDB (for database)

### Installation and Setup
1. Clone the repository:
   ```
   git clone https://github.com/yourusername/sahtech.git
   ```

2. Set up the backend server:
   ```
   cd SahtechServer
   mvn clean install
   ```

3. Configure the AI component:
   ```
   cd SahtechAI/fastapi_service
   pip install -r requirements.txt
   ```
   - Create a `.env` file with your Groq API key

4. Set up and run the Flutter application:
   ```bash
   cd SahtechFront
   
   # Install Flutter dependencies
   flutter pub get
   
   # Generate launcher icons for all platforms
   flutter pub run flutter_launcher_icons:main
   
   # Check Flutter setup and connected devices
   flutter doctor
   flutter devices
   
   # Run the app (specify platform if needed)
   flutter run                    # Default platform
   flutter run -d chrome         # Web browser
   flutter run -d windows        # Windows desktop
   flutter run -d android        # Android device/emulator
   flutter run -d ios            # iOS device/simulator (macOS only)
   
   # Build for production
   flutter build apk             # Android APK
   flutter build appbundle       # Android App Bundle
   flutter build ios             # iOS (macOS only)
   flutter build web             # Web deployment
   flutter build windows         # Windows executable
   ```

   **Additional Flutter Setup**:
   - Ensure you have the latest Flutter SDK installed
   - For Android development: Android Studio with Android SDK
   - For iOS development: Xcode (macOS only)
   - For web development: Chrome browser
   - For desktop development: Platform-specific requirements

## Future Incoming Features

### Real-Time Communication & Support
- **Real-Time Chat System**: Implementation of Socket.IO for instant messaging between nutritionists and clients
- **Live Nutrition Consultation**: Real-time advice and guidance using gRPC protocol for high-performance communication
- **Feedback System**: Comprehensive user feedback collection and management system
- **AI Mistake Reporting**: Feature allowing users to report AI recommendation errors for continuous improvement

### Subscription & Monetization
- **VIP & Normal User Subscriptions**: Tiered subscription model offering different levels of access
- **Scan-Based Pricing**: Subscription plans based on the number of product scans allowed per period
- **Premium Features Access**: Enhanced features and priority support for VIP subscribers

### Infrastructure & Scalability
- **Kafka with Go**: Implementation of Apache Kafka using Go for distributed log management and event streaming
- **Microservices Enhancement**: Further decomposition into specialized microservices for better scalability
- **Advanced Analytics**: Enhanced monitoring and analytics capabilities for distributed systems
- **Load Balancing**: Implementation of advanced load balancing for high availability

### Technical Improvements
- **Enhanced AI Models**: Integration of more sophisticated machine learning models
- **Multi-Language Support**: Expanded internationalization for global reach
- **Offline Mode**: Cached recommendations and offline functionality
- **Advanced Security**: Enhanced authentication and authorization mechanisms

## Project Status
This project is currently under active development as part of a Startup final year project (Projet de fin d'études L3).

