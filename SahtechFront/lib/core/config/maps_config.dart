class MapsConfig {
  // TODO: Move this to a secure environment configuration
  static const String apiKey = 'YOUR_NEW_API_KEY_HERE';
  
  // Headers for API requests
  static Map<String, String> get apiHeaders => {
    'Accept': 'image/*, */*',
    'Accept-Language': 'en-US,en;q=0.9',
  };
} 