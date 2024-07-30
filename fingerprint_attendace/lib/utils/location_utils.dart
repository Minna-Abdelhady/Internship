// location_utils.dart
import 'dart:math';

// out of bound loaction: 30.07664930397176, 31.315877199665714
// company location: 30.076058613651153, 31.315532711837214

const double companyLatitude = 30.07664930397176;
const double companyLongitude = 31.315877199665714;
const double companyRadius = 50; // Radius in meters

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const int earthRadius = 6371000; // Earth radius in meters
  double dLat = _degreeToRadian(lat2 - lat1);
  double dLon = _degreeToRadian(lon2 - lon1);
  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_degreeToRadian(lat1)) * cos(_degreeToRadian(lat2)) *
      sin(dLon / 2) * sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  return earthRadius * c;
}

double _degreeToRadian(double degree) {
  return degree * pi / 180;
}

bool isWithinCompanyBounds(double userLatitude, double userLongitude) {
  double distance = calculateDistance(companyLatitude, companyLongitude, userLatitude, userLongitude);
  return distance <= companyRadius;
}
