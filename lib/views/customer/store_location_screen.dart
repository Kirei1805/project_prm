import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../../services/location_service.dart';
import '../../utils/app_colors.dart';

class StoreLocationScreen extends StatefulWidget {
  final bool isPickerMode;
  
  const StoreLocationScreen({super.key, this.isPickerMode = false});

  @override
  State<StoreLocationScreen> createState() => _StoreLocationScreenState();
}

class _StoreLocationScreenState extends State<StoreLocationScreen> {
  final LocationService _locationService = LocationService();
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  
  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isGeocoding = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isPickerMode) {
      _initStoreLocation();
    }
  }

  void _initStoreLocation() {
    final storeLatLng = _locationService.getStoreLocation();
    _markers.add(
      Marker(
        markerId: const MarkerId('store_location'),
        position: storeLatLng,
        infoWindow: const InfoWindow(
          title: 'ElectroHub Main Store',
          snippet: 'Your Electronic Components Store',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _onMapTapped(LatLng position) async {
    if (!widget.isPickerMode) return;

    setState(() {
      _selectedLocation = position;
      _isGeocoding = true;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _selectedAddress = '${place.street}, ${place.subAdministrativeArea}, ${place.administrativeArea}';
          _isGeocoding = false;
        });
      }
    } catch (e) {
      setState(() {
        _selectedAddress = 'Address not found';
        _isGeocoding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isPickerMode ? 'Select Delivery Address' : 'Store Location'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _locationService.getStoreLocation(),
              zoom: 15.0,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onTap: _onMapTapped,
          ),
          if (!widget.isPickerMode)
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ElectroHub Main Store',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: AppColors.accent, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Ho Chi Minh City, Vietnam',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: AppColors.accent, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Open: 8:00 AM - 6:00 PM',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          
          if (widget.isPickerMode && _selectedLocation != null)
            Positioned(
              bottom: 30,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Selected Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isGeocoding
                        ? const Center(child: CircularProgressIndicator())
                        : Text(
                            _selectedAddress,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isGeocoding || _selectedAddress.isEmpty || _selectedAddress == 'Address not found'
                          ? null
                          : () {
                              Navigator.pop(context, _selectedAddress);
                            },
                      child: const Text('CONFIRM ADDRESS'),
                    ),
                  ],
                ),
              ),
            ),
            
          if (widget.isPickerMode && _selectedLocation == null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.touch_app, color: AppColors.surface),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap anywhere on the map to select your delivery location',
                        style: TextStyle(color: AppColors.surface, fontWeight: FontWeight.bold),
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
}
