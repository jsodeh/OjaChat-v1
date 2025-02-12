class Config {
  static const String paystackPublicKey = 'your_paystack_public_key';
  static const String paystackSecretKey = 'your_paystack_secret_key';
  static const String fcmServerKey = 'your_fcm_server_key';
  
  // Nigerian Bank Codes for Paystack
  static const Map<String, String> bankCodes = {
    'Access Bank': '044',
    'Zenith Bank': '057',
    'GTBank': '058',
    'First Bank': '011',
    'UBA': '033',
    'Union Bank': '032',
    'Stanbic IBTC': '221',
    'Sterling Bank': '232',
    'Unity Bank': '215',
    'Wema Bank': '035',
    // Add more banks as needed
  };
  
  // Add other config values here
} 