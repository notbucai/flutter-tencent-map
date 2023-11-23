import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:tencent_map/tencent_map.dart';
import 'package:tencent_map_example/model/location_address.dart';
import 'package:tencent_map_example/tmap_api.dart';
import '../utils.dart';

class ChooseLocation extends StatefulWidget {
  const ChooseLocation({Key? key}) : super(key: key);

  @override
  State<ChooseLocation> createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {
  @override
  void initState() {
    super.initState();
  }

  TencentMapController? _controller;
  // Marker? _centerMarker;

  bool isInitCenter = false;

  Location? _location;
  LocationAddress? _locationAddress;

  List<LocationAddress> _locationAddressList = [];

  void _init(Location location) async {
    _controller?.moveCamera(CameraPosition(
      target: LatLng(
        latitude: location.latitude,
        longitude: location.longitude,
      ),
      zoom: 15,
    ));
    // _centerMarker = await _controller?.addMarket(
    //   MarkerOptions(
    //     position: LatLng(
    //       latitude: location.latitude,
    //       longitude: location.longitude,
    //     ),
    //   ),
    // );
    _updateLocationAddressList(location);
  }

  Future<void> _updateLocationAddressList(Location location) async {
    var list = await _getLocationData(location);
    _locationAddressList = list ?? [];
    if (_locationAddressList.isNotEmpty) {
      _locationAddress = _locationAddressList.first;
      if (context.mounted) {
        setState(() {});
        PrimaryScrollController.of(context).animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
      // move
      _controller?.moveCamera(
        CameraPosition(
          target: LatLng(
            latitude: _locationAddress!.latitude,
            longitude: _locationAddress!.longitude,
          ),
          zoom: 15,
        ),
        const Duration(milliseconds: 300),
      );
    }
  }

  void _updateMarker(Location location) {
    // 如果是定位地址就不更新
    if (_location != null &&
        _location!.latitude == location.latitude &&
        _location!.longitude == location.longitude) {
      return;
    }
    // _centerMarker?.setPosition(LatLng(
    //   latitude: location.latitude,
    //   longitude: location.longitude,
    // ));
  }

  // 加一个防抖
  Timer? _updateCameraLocationDebounceTimer;

  void _updateCameraLocationDebounce(LatLng latLng) {
    // 加一个定时器
    log('_updateCameraLocationDebounce -> $latLng');
    _updateCameraLocationDebounceTimer?.cancel();
    // close
    _updateCameraLocationDebounceTimer =
        Timer(const Duration(milliseconds: 100), () {
      _updateCameraLocation(latLng);
    });
  }

  var _updateCameraLocationIng = false;
  // _updateCameraLocation
  void _updateCameraLocation(LatLng latLng) async {
    // 加一个定时器
    log('_updateCameraLocation -> $latLng');
    if (latLng.latitude == null || latLng.longitude == null) return;
    if (_updateCameraLocationIng) return;
    _updateCameraLocationIng = true;
    setState(() {});
    try {
      var location = Location(
        latitude: latLng.latitude,
        longitude: latLng.longitude,
      );
      // 如果等于当前定位地址就不更新
      if (location.latitude == _location?.latitude &&
          location.longitude == _location?.longitude) {
        return;
      }

      log('location -> $location \n _locationAddress -> $_locationAddress');

      // 如果等于选中地址就不更新
      if (_locationAddress != null) {
        if (location.latitude == _locationAddress?.latitude &&
            location.longitude == _locationAddress?.longitude) {
          return;
        }
        if (_locationAddress!.latitude != null &&
            _locationAddress!.longitude != null) {
          // 如果距离小于 10 米就不更新
          var distance = LocationUtils.getDistance(
            lat1: location.latitude!,
            lng1: location.longitude!,
            lat2: _locationAddress!.latitude!,
            lng2: _locationAddress!.longitude!,
          );

          log('distance -> $distance');
          if (distance < 5) return;
        }
      }

      await _updateLocationAddressList(location);
    } finally {
      _updateCameraLocationIng = false;
      setState(() {});
    }
  }

  Future<List<LocationAddress>?> _getLocationData(Location location) async {
    var lat = location.latitude;
    var lng = location.longitude;
    if (lat == null && lng == null) return null;
    if (lat == 0 && lat == 0) return null;

    var res = await TMapApi.geocoder('$lat,$lng', params: {
      'get_poi': 1,
      'poi_options': 'radius=5000;policy=5',
    });

    log('res -> $res');
    var pois = res?['pois'] as List?;

    List<LocationAddress>? list = res?['pois']?.map<LocationAddress>((e) {
      if (e is Map<String, dynamic>) {
        return LocationAddress.fromPoi(e);
      }
      return LocationAddress();
    }).toList();
    return list;
  }

  void toLocation() {
    if (_location == null) return;
    _controller?.moveCamera(
      CameraPosition(
        target: LatLng(
          latitude: _location!.latitude,
          longitude: _location!.longitude,
        ),
        zoom: 15,
      ),
      const Duration(milliseconds: 100),
    );
  }

  @override
  build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('位置选择'),
        scrolledUnderElevation: 0,
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Flex(
        direction: Axis.vertical,
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                TencentMap(
                  mapType: context.isDark ? MapType.dark : MapType.normal,
                  // myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  myLocationStyle: MyLocationStyle(
                    myLocationType: MyLocationType.followNoCenter,
                  ),
                  onTap: logger('onTap'),
                  onTapPoi: logger('onTapPoi'),
                  onLongPress: logger('onLongPress'),
                  onMarkerDrag: ((markerId, latLng) {
                    print('onMarkerDrag -> $markerId, $latLng');
                  }),
                  onCameraMove: (position) async {
                    log('---->>> onCameraMove -> ${position.target?.encode()}');
                    if (position.target == null) return;
                    _updateMarker(Location(
                      latitude: position.target!.latitude,
                      longitude: position.target!.longitude,
                    ));
                  },
                  onCameraIdle: (position) {
                    log('---->>> onCameraIdle -> ${position.target?.encode()}');
                    if (position.target == null) return;
                    print('onCameraIdle -> ${position.target!.encode()}');
                    _updateCameraLocationDebounce(position.target!);
                  },
                  onLocation: (location) {
                    _location = location;
                    if (!isInitCenter && _controller != null) {
                      isInitCenter = true;
                      _init(location);
                    }
                  },
                  onMapCreated: (controller) async {
                    _controller = controller;
                  },
                ),
                Center(
                  child: Transform.translate(
                    offset: const Offset(0, -10),
                    child: const Icon(
                      Icons.location_on_sharp,
                      color: Colors.blueAccent,
                      size: 36,
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(4),
                      onTap: () {
                        toLocation();
                      },
                      child: Ink(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              offset: const Offset(0, 2),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.my_location_rounded,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              child: Column(
                children: [
                  ChooseLocationSearchBar(
                    location: _location,
                    onSubmitted: (data) {
                      print('data -> $data');
                      _controller?.moveCamera(
                        CameraPosition(
                          target: LatLng(
                            latitude: data['lat'],
                            longitude: data['lng'],
                          ),
                          zoom: 15,
                        ),
                        const Duration(milliseconds: 300),
                      );
                    },
                  ),
                  Visibility(
                    visible: _updateCameraLocationIng,
                    child: const LinearProgressIndicator(
                      color: Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      primary: true,
                      itemCount: _locationAddressList.length,
                      // 线
                      separatorBuilder: (context, index) {
                        return Divider(
                          height: 0.5,
                          color: Colors.grey.withOpacity(.2),
                          indent: 12,
                          endIndent: 12,
                        );
                      },
                      itemBuilder: (context, index) {
                        var item = _locationAddressList[index];
                        var isSelected = _locationAddress?.id == item.id;
                        return ListTile(
                          onTap: () {
                            _locationAddress = item;
                            _controller?.moveCamera(
                                CameraPosition(
                                  target: LatLng(
                                    latitude: item.latitude,
                                    longitude: item.longitude,
                                  ),
                                  zoom: 15,
                                ),
                                const Duration(milliseconds: 300));
                            setState(() {});
                          },
                          leading: const Icon(
                            Icons.location_on_outlined,
                            color: Colors.grey,
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.blueAccent,
                                  size: 18,
                                )
                              : const SizedBox(),
                          title: Text(item.title ?? ''),
                          subtitle: Text(item.address ?? ''),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  logger(String name) {
    // ignore: avoid_print
    return (dynamic data) => print('$name: ${data.encode()}');
  }
}

class ChooseLocationSearchBar extends StatefulWidget {
  const ChooseLocationSearchBar({
    Key? key,
    this.location,
    this.onSubmitted,
  }) : super(key: key);

  final Location? location;

  final void Function(Map data)? onSubmitted;

  @override
  State<StatefulWidget> createState() {
    return _ChooseLocationSearchBar();
  }
}

class _ChooseLocationSearchBar extends State<ChooseLocationSearchBar> {
  ValueNotifier<List<Map>> suggestion = ValueNotifier([]);
  // loading
  ValueNotifier<bool> loading = ValueNotifier(false);
  // error
  ValueNotifier<String?> error = ValueNotifier(null);
  // empty
  ValueNotifier<bool> empty = ValueNotifier(false);

  Widget buildSearch(
    bool enabled, {
    void Function(String)? onSubmitted,
  }) {
    return TextField(
      maxLength: 11,
      // 禁用
      enabled: enabled,
      autofocus: true,
      decoration: InputDecoration(
        hintText: '搜索地点',
        fillColor: Colors.grey.withOpacity(0.1),
        // background color
        filled: true,
        // radius
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8,
        ),
        prefixIcon: const Icon(Icons.search),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 36,
        ),
        prefixIconColor: Colors.grey,
        counterText: '',
      ),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      onSubmitted: (value) {
        print('onSubmitted -> $value');
        onSubmitted?.call(value);
      },
    );
  }

  Future<void> search(String k) async {
    var location = widget.location;

    loading.value = true;
    error.value = null;
    empty.value = false;

    try {
      Map<String, dynamic> params = {
        'page_size': 20,
      };

      if (location != null) {
        params['location'] = '${location!.latitude},${location!.longitude}';
      }

      var value = await TMapApi.suggestion(
        k,
        params: params,
      );
      suggestion.value = value?.map(
            (e) {
              return {
                'title': e['title'],
                'address': e['address'],
                'lat': e['location']['lat'],
                'lng': e['location']['lng'],
              };
            },
          ).toList() ??
          [];
      print('value -> $value');
      empty.value = suggestion.value.isEmpty;
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  void showSearchDialog(BuildContext context) async {
    showBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                child: buildSearch(
                  true,
                  onSubmitted: (value) {
                    print('onSubmitted -> $value');
                    search(value);
                  },
                ),
              ),
              Column(
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: loading,
                    builder: (context, value, child) {
                      if (value) {
                        return const LinearProgressIndicator(
                          color: Colors.blue,
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                  ValueListenableBuilder<String?>(
                    valueListenable: error,
                    builder: (context, value, child) {
                      if (value != null) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          child: Text(
                            value,
                            style: const TextStyle(
                              color: Colors.redAccent,
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: empty,
                    builder: (context, value, child) {
                      if (value) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          child: const Text(
                            '没有搜索到结果',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ],
              ),
              Expanded(
                child: ValueListenableBuilder<List<Map>>(
                  valueListenable: suggestion,
                  builder: (valueContext, value, child) {
                    print('value ->>>>>> $value');
                    return ListView.separated(
                      itemCount: value.length,
                      // 线
                      separatorBuilder: (context, index) {
                        return Divider(
                          height: 0.5,
                          color: Colors.grey.withOpacity(.2),
                          indent: 12,
                          endIndent: 12,
                        );
                      },
                      itemBuilder: (itemContext, index) {
                        return ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            widget.onSubmitted?.call(value[index]);
                          },
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 12,
                          ),
                          leading: const Icon(
                            Icons.location_on_outlined,
                            color: Colors.grey,
                          ),
                          title: Text(value[index]['title']),
                          subtitle: Text(value[index]['address']),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showSearchDialog(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.3),
            ),
          ),
        ),
        child: buildSearch(false),
      ),
    );
  }
}
