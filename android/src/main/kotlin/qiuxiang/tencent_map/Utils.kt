package qiuxiang.tencent_map

import android.graphics.BitmapFactory
import android.location.Location
import com.tencent.tencentmap.mapsdk.maps.model.*
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding

fun Pigeon.LatLng.toLatLng(): LatLng {
  return LatLng(latitude ?: 0.0, longitude ?: 0.0)
}

fun LatLng.toLatLng(): Pigeon.LatLng {
  return Pigeon.LatLng.Builder().setLatitude(latitude).setLongitude(longitude).build()
}

fun MapPoi.toMapPoi(): Pigeon.MapPoi {
  return Pigeon.MapPoi.Builder().setName(name).setPosition(position.toLatLng()).build()
}

fun CameraPosition.toCameraPosition(): Pigeon.CameraPosition {
  return Pigeon.CameraPosition.Builder().setBearing(bearing.toDouble()).setTarget(target.toLatLng())
    .setTilt(tilt.toDouble()).setZoom(zoom.toDouble()).build()
}

fun Pigeon.CameraPosition.toCameraPosition(cameraPosition: CameraPosition): CameraPosition {
  return CameraPosition.Builder().let { builder ->
    builder.target(target?.toLatLng() ?: cameraPosition.target)
    builder.tilt(tilt?.toFloat() ?: cameraPosition.tilt)
    builder.zoom(zoom?.toFloat() ?: cameraPosition.zoom)
    builder.bearing(bearing?.toFloat() ?: cameraPosition.bearing)
    builder.build()
  }
}

fun Pigeon.Location.toLocation(): Location {
  return Location("tencent_map").let { location ->
    latitude?.let { location.latitude = it }
    longitude?.let { location.longitude = it }
    accuracy?.let { location.accuracy = it.toFloat() }
    bearing?.let { location.bearing = it.toFloat() }
    location
  }
}

fun Pigeon.MyLocationStyle.toMyLocationStyle(): MyLocationStyle {
  return MyLocationStyle().let { style ->
    myLocationType?.let {
      style.myLocationType(
        when (it) {
          Pigeon.MyLocationType.FOLLOW_NO_CENTER -> MyLocationStyle.LOCATION_TYPE_FOLLOW_NO_CENTER
          Pigeon.MyLocationType.LOCATION_ROTATE -> MyLocationStyle.LOCATION_TYPE_LOCATION_ROTATE
          Pigeon.MyLocationType.LOCATION_ROTATE_NO_CENTER -> MyLocationStyle.LOCATION_TYPE_LOCATION_ROTATE_NO_CENTER
          Pigeon.MyLocationType.MAP_ROTATE_NO_CENTER -> MyLocationStyle.LOCATION_TYPE_MAP_ROTATE_NO_CENTER
        }
      )
    }
    style
  }
}

fun Pigeon.MarkerOptions.toMarkerOptions(binding: FlutterPluginBinding): MarkerOptions {
  return MarkerOptions(position.toLatLng()).let { options ->
    icon?.toBitmapDescriptor(binding)?.let { options.icon(it) }
    rotation?.toFloat()?.let { options.rotation(it) }
    alpha?.toFloat()?.let { options.alpha(it) }
    flat?.let { options.flat(it) }
    anchor?.let { options.anchor(it[0].toFloat(), it[1].toFloat()) }
    draggable?.let { options.draggable(it) }
    zIndex?.let { options.zIndex(it.toFloat()) }
    options
  }
}

fun Pigeon.Bitmap.toBitmapDescriptor(binding: FlutterPluginBinding): BitmapDescriptor? {
  asset?.let {
    return BitmapDescriptorFactory.fromAsset(binding.flutterAssets.getAssetFilePathByName(it))
  }
  bytes?.let {
    return BitmapDescriptorFactory.fromBitmap(BitmapFactory.decodeByteArray(it, 0, it.size))
  }
  return null
}