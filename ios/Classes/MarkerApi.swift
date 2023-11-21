import QMapKit

class _MarkerApi: NSObject, MarkerApi {
    let mapView: QMapView
    let api: _TencentMapApi

    init(_ mapView: QMapView, _ api :_TencentMapApi ) {
        self.mapView = mapView
        self.api = api
    }

    func getAnnotationById(_ id: String ) -> QPointAnnotation? {
        print("getAnnotationById id is \(id)")
        var _annotation:QPointAnnotation? = nil
        api.annotationInfoId.forEach { (annotation, aId) in
            if aId == id {
                print("getAnnotationById yes id is \(id)")
                _annotation = annotation
            }
        }
        return _annotation
    }

    func removeId(_ id: String, error _: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        // 实现 remove 方法的逻辑
        // ...
        if let annotation = getAnnotationById(id) {
            mapView.removeAnnotation(annotation)
        }
    }

    func setRotationId(_ id: String, rotation: NSNumber, error _: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        // 实现 setRotation 方法的逻辑
        // ...
    }

    func setPositionId(_ id: String, position: LatLng, error _: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        // 实现 setPosition 方法的逻辑
        // ...
        print("setPositionId \(position)")
        // latitude 和 longitude 是 NSNumber? 类型，需要转换为 double 类型
        if let latitude = position.latitude, let longitude = position.longitude {
            print("setPositionId \(latitude) \(longitude)")
            // 设置annotationView的位置
            // pinView.annotation.coordinate = CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
            // annotationInfoId [annotation: String]
            // 通过id找到annotation
            if let annotation = getAnnotationById(id) {
                annotation.coordinate = CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
            }
        }

    }

    func setAnchorId(_ id: String, x: NSNumber, y: NSNumber, error _: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        // 实现 setAnchor 方法的逻辑
        // ...
    }

    func setZIndexId(_ id: String, zIndex: NSNumber, error _: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        // 实现 setZIndex 方法的逻辑
        // ...
    }

    func setAlphaId(_ id: String, alpha: NSNumber, error _: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        // 实现 setAlpha 方法的逻辑6
        // ...
    }

    func setIconId(_ id: String, icon: Bitmap, error _: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        // 实现 setIcon 方法的逻辑
        // ...
    }

    func setDraggableId(_ id: String, draggable: NSNumber, error _: AutoreleasingUnsafeMutablePointer<FlutterError?>) {
        // 实现 setDraggable 方法的逻辑
        // ...
    }
}
