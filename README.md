# SAHTECH

## Overview
Sahtech is a comprehensive health and nutrition platform designed to help users make informed decisions about food products. The platform consists of multiple integrated components:

1. **Mobile Application** - A Flutter-based mobile app for users to scan food products, receive personalized recommendations, and manage their health profiles.
2. **Backend Server** - A Spring Boot server that handles user authentication, data storage, and business logic.
3. **AI Component** - An AI-powered recommendation system that analyzes food products based on user health profiles.
4. **Static Website** - A descriptive website that showcases the platform's features and benefits.
5. **Collaboration Form** - A system for advertisers and partners to submit collaboration requests.
6. **Analytics Dashboard** - A dashboard to monitor user metrics, downloads, and platform performance.

![Sahtech Logo](https://github.com/yourusername/sahtech/raw/main/images/sahtech_logo.png)

## Platform Screenshots

### Mobile Application
![Mobile App Home](https://github.com/yourusername/sahtech/raw/main/images/mobile_home.png)
![Mobile App Scan](https://github.com/yourusername/sahtech/raw/main/images/mobile_scan.png)
![Mobile App Onboarding](https://github.com/yourusername/sahtech/raw/main/images/mobile_onboarding.png)
![Mobile App Product Analysis](https://github.com/yourusername/sahtech/raw/main/images/mobile_product_analysis.png)
![Mobile App Barcode Scanner](https://github.com/yourusername/sahtech/raw/main/images/mobile_barcode_scanner.png)

### Website
![Sahtech Website](https://github.com/yourusername/sahtech/raw/main/images/website_landing.png)

### Analytics Dashboard
![Sahtech Dashboard](https://github.com/yourusername/sahtech/raw/main/images/dashboard.png)

## Platform Components

### Mobile Application
- **Technology**: Flutter (cross-platform)
- **Features**:
  - Barcode scanning for food products
  - Personalized recommendations based on health profile
  - User profile management (allergies, chronic diseases, preferences)
  - Nutritionist contact and consultation
  - History of scanned products

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
- **Purpose**: Allow businesses to submit advertising requests
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

4. Run the Flutter application:
   ```
   cd SahtechFront
   flutter pub get
   flutter run
   ```

## Project Status
This project is currently under active development as part of a final year project (Projet fin d'etude L3).

## Contributors
- Idris (Backend)
- Raouf (Mobile App)
- [Add other team members]

## License
[Specify license information]
