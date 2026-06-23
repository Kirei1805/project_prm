import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'firestore_service.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Vui lòng bật GPS/Vị trí trên điện thoại của bạn.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Bạn đã từ chối cấp quyền vị trí.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Quyền vị trí bị chặn vĩnh viễn. Vui lòng vào Cài đặt máy để mở lại.');
    }

    return await Geolocator.getCurrentPosition();
  }

  // Fetch store location from Firestore
  Future<LatLng> getStoreLocation() async {
    final firestoreService = FirestoreService();
    return await firestoreService.getStoreLocation();
  }
}
