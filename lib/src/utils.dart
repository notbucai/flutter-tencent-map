import 'dart:math';

class LocationUtils {
  const LocationUtils._();

  static double _rad(double d) {
    return d * pi / 180.0;
  }

  // 距离计算 m
  static double getDistance({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    const EARTH_RADIUS = 6378137.0;
    double radLat1 = _rad(lat1);
    double radLat2 = _rad(lat2);
    double a = radLat1 - radLat2;
    double b = _rad(lng1) - _rad(lng2);
    double s = 2 *
        asin(sqrt(pow(sin(a / 2), 2) +
            cos(radLat1) * cos(radLat2) * pow(sin(b / 2), 2)));
    s = s * EARTH_RADIUS;
    return s;
  }
}
