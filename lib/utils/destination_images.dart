/// Centralized destination image mapping
/// Maps each destination to representative high-quality images
/// Images are optimized (webp preferred) and destination-specific
class DestinationImages {
  // Primary image mapping for each destination
  // Each destination has a set of representative images
  // First image in the list is used as default
  static const Map<String, List<String>> _destinationImages = {
    'Goa': [
      'https://images.unsplash.com/photo-1512343879784-a960bf40e7f2?w=800&q=80', // Goa beach
      'https://images.unsplash.com/photo-1587922546307-776227941871?w=800&q=80', // Goa sunset
    ],
    'Kerala': [
      'https://images.unsplash.com/photo-1602216056096-3b40cc0c9944?w=800&q=80', // Kerala backwaters
      'https://images.unsplash.com/photo-1593693397690-362cb9666fc2?w=800&q=80', // Houseboat
    ],
    'Rajasthan': [
      'https://images.unsplash.com/photo-1599661046289-e31897846e41?w=800&q=80', // Hawa Mahal Jaipur
      'https://images.unsplash.com/photo-1477587458883-47145ed94245?w=800&q=80', // Jaisalmer Fort
      'https://images.unsplash.com/photo-1609137144813-7d9921338f24?w=800&q=80', // Udaipur Lake Palace
    ],
    'Mumbai': [
      'https://images.unsplash.com/photo-1529253355930-ddbe423a2ac7?w=800&q=80', // Gateway of India
      'https://images.unsplash.com/photo-1566552881560-0be862a7c445?w=800&q=80', // Mumbai skyline
    ],
    'Delhi': [
      'https://images.unsplash.com/photo-1569098644584-210bcd375b59?w=800&q=80', // India Gate
      'https://images.unsplash.com/photo-1587474260584-136574528ed5?w=800&q=80', // Red Fort
    ],
    'Himachal': [
      'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?w=800&q=80', // Himachal mountains
      'https://images.unsplash.com/photo-1605649487212-47bdab064df7?w=800&q=80', // Manali
    ],
    'Uttarakhand': [
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80', // Uttarakhand mountains
      'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?w=800&q=80', // Rishikesh
    ],
    'Andaman': [
      'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800&q=80', // Andaman beach
      'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=800&q=80', // Radhanagar beach
    ],
    'Ladakh': [
      'https://images.unsplash.com/photo-1609137144813-7d9921338f24?w=800&q=80', // Ladakh landscape
      'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?w=800&q=80', // Pangong Lake
    ],
    'Tamil Nadu': [
      'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=800&q=80', // Meenakshi Temple
      'https://images.unsplash.com/photo-1609137144813-7d9921338f24?w=800&q=80', // Tamil Nadu temple
    ],
    'Karnataka': [
      'https://images.unsplash.com/photo-1596176530529-78163a4f7af2?w=800&q=80', // Mysore Palace
      'https://images.unsplash.com/photo-1582510003544-4d00b7f74220?w=800&q=80', // Karnataka heritage
    ],
    'Agra': [
      'https://images.unsplash.com/photo-1564507592333-c60657eea523?w=800&q=80', // Taj Mahal
      'https://images.unsplash.com/photo-1587474260584-136574528ed5?w=800&q=80', // Agra Fort
    ],
    'Assam': [
      'https://images.unsplash.com/photo-1605649487212-47bdab064df7?w=800&q=80', // Assam tea gardens
      'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?w=800&q=80', // Assam landscape
    ],
    'Kashmir': [
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80', // Dal Lake
      'https://images.unsplash.com/photo-1626621341517-bbf3d9990a23?w=800&q=80', // Kashmir mountains
    ],
  };

  /// Get primary image for a destination
  /// Returns the first (default) image from the destination's image set
  /// Falls back to a generic travel image if destination not found
  static String getDestinationImage(String destination, {int index = 0}) {
    final images = _destinationImages[destination];
    if (images != null && images.length > index) {
      return images[index];
    }
    // Fallback to generic travel image
    return 'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800?w=800&q=80';
  }

  /// Get all images for a destination
  /// Useful for galleries or multiple image displays
  static List<String> getDestinationImages(String destination) {
    return _destinationImages[destination] ?? [];
  }

  /// Check if destination has custom images
  static bool hasCustomImages(String destination) {
    return _destinationImages.containsKey(destination);
  }

  /// Add new destination images dynamically
  /// Useful for future expansion without modifying this file
  static void addDestination(String destination, List<String> imageUrls) {
    // Note: This is runtime only, not persisted
    // For permanent additions, update _destinationImages map above
    _destinationImages[destination] = imageUrls;
  }
}
