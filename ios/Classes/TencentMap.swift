import Flutter
import QMapKit
import CoreFoundation

class TencentMapFactory: NSObject, FlutterPlatformViewFactory {
    let registrar: FlutterPluginRegistrar

    init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
    }

    func create(withFrame _: CGRect, viewIdentifier _: Int64, arguments _: Any?) -> FlutterPlatformView {
        MapView(registrar)
    }
}

class MapView: NSObject, FlutterPlatformView, QMapViewDelegate {
    let mapView: QMapView
    let api: _TencentMapApi
    let handler:TencentMapHandler
    let registrar:FlutterPluginRegistrar
    
    static let id:String = "pointAnnotation"

    init(_ registrar: FlutterPluginRegistrar) {
        mapView = QMapView()
        api = _TencentMapApi(mapView)
        
        TencentMapApiSetup(registrar.messenger(), api)
        MarkerApiSetup(registrar.messenger(), _MarkerApi(mapView, api))
        handler = TencentMapHandler.init(binaryMessenger: registrar.messenger())
        self.registrar = registrar;
        super.init()
        mapView.delegate = self
    }

    func view() -> UIView {
        mapView
    }
    func mapView(_ mapView: QMapView!, didTapAt coordinate: CLLocationCoordinate2D) {
        let latLng = LatLng.make(withLatitude: NSNumber(value: coordinate.latitude), longitude: NSNumber(value: coordinate.longitude));
        handler.onTap(latLng) { e in
            print("onTap ERROR:\(e)")
        }
    }
    
    func mapView(_ mapView: QMapView!, viewFor annotation: QAnnotation!) -> QAnnotationView? {
        if annotation is QPointAnnotation{
            
            if let id = api.annotationInfoId[annotation as! QPointAnnotation] {
                print("id is \(id)")
                    
                var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? QPinAnnotationView
                if let pinView = pinView{
                    return pinView
                }
                pinView = QPinAnnotationView(annotation: annotation, reuseIdentifier: id)
                pinView?.canShowCallout = true
                
                if let option = api.annotationInfo[annotation as! QPointAnnotation] {
                    let key = registrar.lookupKey(forAsset: option.icon?.asset ?? "")
                    if let path = Bundle.main.path(forResource: key, ofType:Optional.none){
                        pinView?.image = UIImage(contentsOfFile: path)
                    }
                }
                return pinView
            }

        }
        return Optional.none
    }
    static var subViews:[QAnnotationView] = [];
    func mapView(_ mapView: QMapView!, didAdd views: [QAnnotationView]!) {
        MapView.subViews = views;
    }
    func mapViewRegionChange(_ mapView: QMapView!) {
        let loc = mapView.region.center
        let pos = CameraPosition()
        pos.target = LatLng.make(withLatitude: NSNumber(value: loc.latitude), longitude: NSNumber(value: loc.longitude));
        handler.onCameraMove(pos) { e in
            print("mapViewRegionChange ERROR:\(e)")
        }
    }

    // 实现可选协议方法
    func mapView(_ mapView: QMapView, didMoveAnimated animated: Bool, gesture bGesture: Bool) {
        print("mapView didMoveAnimated \(animated) gesture \(bGesture)")
        let loc = mapView.region.center
        let pos = CameraPosition()
        pos.target = LatLng.make(withLatitude: NSNumber(value: loc.latitude), longitude: NSNumber(value: loc.longitude));
        handler.onCameraIdleCameraPosition(pos) { e in
            print("regionDidChangeAnimated ERROR:\(e)")
        }
    }

    // didUpdateUserLocation
    // func mapView(_ mapView: QMapView!, didUpdateUserLocation userLocation: QUserLocation!, fromHeading: Bool) {
    func mapView(_ mapView: QMapView, didUpdate userLocation: QUserLocation, fromHeading: Bool) {
        print("mapView didUpdateUserLocation \(userLocation) fromHeading \(fromHeading)")
        // CLLocation
        let location = userLocation.location

        print("location \(location)")
        if let it = location {
            print("location.coordinate \(it.coordinate)")
            var loc = Location()
            var coordinate = it.coordinate
            loc.latitude = NSNumber(value: coordinate.latitude)
            loc.longitude = NSNumber(value: coordinate.longitude)
            print("loc \(loc) \(it.altitude)")

            handler.onLocationLocation(loc) { e in
                print("onLocationLocation ERROR:\(e)")
            }
        }
    }
    // didFailToLocateUserWithError
    func mapView(_ mapView: QMapView!, didFailToLocateUserWithError error: Error!) {
        print("mapView didFailToLocateUserWithError \(error)")
    }
    
    func update(_ options: MarkerOptions,annotation:QPointAnnotation){
//        subViews.forEach { view in
//            if(view.annotation as? QPointAnnotation == annotation){
//                view.annotation?.coordinate = CLLocationCoordinate2DMake(options.position.latitude!.doubleValue, options.position.longitude!.doubleValue)
//            }
//        }
    }
}