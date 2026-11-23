/// Static dataset for Tamil Nadu districts and popular areas, optimized for local leaderboard rivalry.
class TamilNaduLocations {
  TamilNaduLocations._();

  static const String defaultState = 'Tamil Nadu';

  static const List<String> states = [
    'Tamil Nadu',
    'Kerala',
    'Karnataka',
    'Andhra Pradesh',
    'Telangana',
    'Maharashtra',
    'Delhi',
  ];

  /// All 38 administrative districts of Tamil Nadu
  static const List<String> districts = [
    'Ariyalur',
    'Chengalpattu',
    'Chennai',
    'Coimbatore',
    'Cuddalore',
    'Dharmapuri',
    'Dindigul',
    'Erode',
    'Kallakurichi',
    'Kanchipuram',
    'Kanyakumari',
    'Karur',
    'Krishnagiri',
    'Madurai',
    'Mayiladuthurai',
    'Nagapattinam',
    'Namakkal',
    'Nilgiris',
    'Perambalur',
    'Pudukkottai',
    'Ramanathapuram',
    'Ranipet',
    'Salem',
    'Sivaganga',
    'Tenkasi',
    'Thanjavur',
    'Theni',
    'Thoothukudi',
    'Tiruchirappalli',
    'Tirunelveli',
    'Tirupathur',
    'Tiruppur',
    'Tiruvallur',
    'Tiruvannamalai',
    'Tiruvarur',
    'Vellore',
    'Viluppuram',
    'Virudhunagar',
  ];

  /// Prominent zones/areas for high-density Tamil Nadu districts
  static const Map<String, List<String>> popularAreasByDistrict = {
    'Chennai': [
      'Adyar',
      'Anna Nagar',
      'Besant Nagar',
      'Chromepet',
      'Guindy',
      'KK Nagar',
      'Mylapore',
      'Nungambakkam',
      'OMR / Thoraipakkam',
      'Perambur',
      'Porur',
      'T. Nagar',
      'Tambaram',
      'Velachery',
      'Vadapalani',
    ],
    'Coimbatore': [
      'Gandhipuram',
      'RS Puram',
      'Peelamedu',
      'Saibaba Colony',
      'Saravanampatti',
      'Singanallur',
      'Ramanathapuram',
      'Ukkadam',
    ],
    'Madurai': [
      'Anna Nagar',
      'KK Nagar',
      'Simmakkal',
      'Tallakulam',
      'Mattuthavani',
      'Teppakulam',
      'SS Colony',
    ],
    'Tiruchirappalli': [
      'Thillai Nagar',
      'KK Nagar',
      'Cantonment',
      'Srirangam',
      'Kattur',
      'Ponmalai',
    ],
    'Salem': [
      'Fairlands',
      'Hasthampatti',
      'Alagapuram',
      'Suramangalam',
      'Shevapet',
      'Ammapet',
    ],
  };

  /// Returns suggested areas for a given district, or a default list if district is not indexed.
  static List<String> getAreasForDistrict(String district) {
    return popularAreasByDistrict[district] ?? ['Central', 'North', 'South', 'East', 'West'];
  }
}
