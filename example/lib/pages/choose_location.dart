import 'package:flutter/material.dart';
import 'package:tencent_map/tencent_map.dart';
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
  Marker? _centerMarker;

  bool isInitCenter = false;

  Location? _location;

  void _init(Location location) async {
    _controller?.moveCamera(CameraPosition(
      target: LatLng(
        latitude: location.latitude,
        longitude: location.longitude,
      ),
      zoom: 20,
    ));
    _centerMarker = await _controller?.addMarket(
      MarkerOptions(
        position: LatLng(
          latitude: location.latitude,
          longitude: location.longitude,
        ),
      ),
    );
  }

  void _updateMarker(Location location) {
    print('_centerMarker -> $_centerMarker');
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
                  onCameraIdle: (position) {
                    if (position.target == null) return;
                    print('onCameraIdle -> ${position.target!.encode()}');
                  },
                  onMarkerDrag: ((markerId, latLng) {
                    print('onMarkerDrag -> $markerId, $latLng');
                  }),
                  onCameraMove: (position) async {
                    if (position.target == null) return;
                    _updateMarker(Location(
                      latitude: position.target!.latitude,
                      longitude: position.target!.longitude,
                    ));
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
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              child: Column(
                children: [
                  const ChooseLocationSearchBar(),
                  Expanded(
                    child: ListView.separated(
                      itemCount: 100,
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
                        return ListTile(
                          leading: const Icon(
                            Icons.location_on_outlined,
                            color: Colors.grey,
                          ),
                          trailing: const Icon(
                            Icons.check,
                            color: Colors.blueAccent,
                            size: 18,
                          ),
                          title: Text('item $index'),
                          subtitle: Text('item $index'),
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

class ChooseLocationSearchBar extends StatelessWidget {
  const ChooseLocationSearchBar({Key? key}) : super(key: key);

  Widget buildSearch(bool enabled) {
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
    );
  }

  void showSearchDialog(BuildContext context) {
    // fix bug
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
                child: buildSearch(true),
              ),
              // Expanded(child: ListView.separated(itemBuilder: itemBuilder, separatorBuilder: separatorBuilder, itemCount: itemCount)),
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
