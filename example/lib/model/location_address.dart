class LocationAddress {
  String? dirDesc;

  int? distance;

  String? category;

  String? address;

  String? title;

  String? id;

  double? latitude;
  double? longitude;

  String? district;

  String? city;

  String? province;

  int? adcode;

  LocationAddress({
    this.dirDesc,
    this.distance,
    this.category,
    this.address,
    this.title,
    this.id,
    this.latitude,
    this.longitude,
    this.district,
    this.city,
    this.province,
    this.adcode,
  });

  static LocationAddress fromPoi(Map<String, dynamic> map) {
    return LocationAddress(
      dirDesc: map['dir_desc'],
      distance: map['distance'],
      category: map['category'],
      address: map['address'],
      title: map['title'],
      id: map['id'],
      // location
      latitude: map['location']?['lat'],
      longitude: map['location']?['lng'],
      // ad_info
      district: map['ad_info']?['district'],
      city: map['ad_info']?['city'],
      province: map['ad_info']?['province'],
      adcode: map['ad_info']?['adcode'],
    );
  }

  // toString
  @override
  String toString() {
    return 'LocationAddress{dirDesc: $dirDesc, distance: $distance, category: $category, address: $address, title: $title, id: $id, latitude: $latitude, longitude: $longitude, district: $district, city: $city, province: $province, adcode: $adcode}';
  }
}
