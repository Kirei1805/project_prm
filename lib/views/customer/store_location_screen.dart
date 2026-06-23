import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import '../../services/location_service.dart';
import '../../services/firestore_service.dart';
import '../../utils/app_colors.dart';

class StoreLocationScreen extends StatefulWidget {
  final bool isPickerMode;
  final bool isAdminMode;
  
  const StoreLocationScreen({super.key, this.isPickerMode = false, this.isAdminMode = false});

  @override
  State<StoreLocationScreen> createState() => _StoreLocationScreenState();
}

class _StoreLocationScreenState extends State<StoreLocationScreen> {
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();
  final List<Marker> _markers = [];
  
  LatLng? _storeLocation;
  bool _isLoading = true;

  LatLng? _selectedLocation;
  String _selectedAddress = '';
  bool _isGeocoding = false;

  String _storeAddressInfo = '';
  String _storeOpenHours = '';
  final TextEditingController _addressInfoController = TextEditingController();
  final TextEditingController _openHoursController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchStoreLocation();
  }

  Future<void> _fetchStoreLocation() async {
    final firestoreService = FirestoreService();
    final settings = await firestoreService.getStoreSettings();
    final location = settings['location'] as LatLng;
    
    if (mounted) {
      setState(() {
        _storeLocation = location;
        _storeAddressInfo = settings['address'] as String;
        _storeOpenHours = settings['openHours'] as String;
        
        _addressInfoController.text = _storeAddressInfo;
        _openHoursController.text = _storeOpenHours;
        
        _isLoading = false;
      });
      if (!widget.isPickerMode && !widget.isAdminMode) {
        _initStoreMarker(location);
      } else if (widget.isAdminMode) {
        // Show current store location marker as editable
        _selectedLocation = location;
        _markers.add(
          Marker(
            point: location,
            width: 60,
            height: 60,
            child: const Icon(
              Icons.location_on,
              color: AppColors.accent,
              size: 50,
            ),
          ),
        );
      }
    }
  }

  void _initStoreMarker(LatLng storeLatLng) {
    _markers.add(
      Marker(
        point: storeLatLng,
        width: 60,
        height: 60,
        child: const Icon(
          Icons.location_on,
          color: AppColors.accent,
          size: 50,
        ),
      ),
    );
  }

  Future<void> _onMapTapped(TapPosition tapPosition, LatLng position) async {
    if (!widget.isPickerMode && !widget.isAdminMode) return;

    setState(() {
      _selectedLocation = position;
      _isGeocoding = true;
      _markers.clear();
      _markers.add(
        Marker(
          point: position,
          width: 60,
          height: 60,
          child: const Icon(
            Icons.location_on,
            color: AppColors.accent,
            size: 50,
          ),
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

  Future<void> _moveToCurrentLocation({bool showError = true}) async {
    try {
      final position = await _locationService.getCurrentLocation();
      final userLatLng = LatLng(position.latitude, position.longitude);
      _mapController.move(userLatLng, 15.0);
      
      // Optionally add a marker for user's location if in picker mode
      if (widget.isPickerMode) {
        _onMapTapped(TapPosition(Offset.zero, Offset.zero), userLatLng);
      }
    } catch (e) {
      if (mounted && showError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.isAdminMode ? 'Edit Store Location' : (widget.isPickerMode ? 'Select Delivery Address' : 'Store Location'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAdminMode ? 'Edit Store Location' : (widget.isPickerMode ? 'Select Delivery Address' : 'Store Location')),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _storeLocation!,
              initialZoom: 15.0,
              onTap: _onMapTapped,
              onMapReady: () {
                if (widget.isPickerMode) {
                  _moveToCurrentLocation(showError: false);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.project_prm',
              ),
              MarkerLayer(
                markers: _markers,
              ),
            ],
          ),
          
          // My Location Button
          Positioned(
            bottom: (widget.isPickerMode || widget.isAdminMode) && _selectedLocation != null ? 180 : ((widget.isPickerMode || widget.isAdminMode) ? 30 : 160),
            right: 16,
            child: FloatingActionButton(
              heroTag: 'my_location',
              backgroundColor: AppColors.surface,
              onPressed: _moveToCurrentLocation,
              child: const Icon(Icons.my_location, color: AppColors.accent),
            ),
          ),
          
          if (!widget.isPickerMode && !widget.isAdminMode)
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ElectroHub Main Store',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.accent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _storeAddressInfo,
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: AppColors.accent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Open: $_storeOpenHours',
                            style: const TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          
          if ((widget.isPickerMode || widget.isAdminMode) && _selectedLocation != null)
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
                    Text(
                      widget.isAdminMode ? 'New Store Location' : 'Selected Address',
                      style: const TextStyle(
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
                    if (widget.isAdminMode) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _addressInfoController,
                        decoration: const InputDecoration(
                          labelText: 'Store Address Display',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _openHoursController,
                        decoration: const InputDecoration(
                          labelText: 'Opening Hours',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isGeocoding || _selectedLocation == null
                          ? null
                          : () async {
                              if (widget.isAdminMode) {
                                final firestoreService = FirestoreService();
                                await firestoreService.updateStoreLocation(
                                  _selectedLocation!,
                                  address: _addressInfoController.text,
                                  openHours: _openHoursController.text,
                                );
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Store location updated successfully!'), backgroundColor: Colors.green));
                                  Navigator.pop(context);
                                }
                              } else {
                                if (_selectedAddress.isNotEmpty && _selectedAddress != 'Address not found') {
                                  Navigator.pop(context, _selectedAddress);
                                }
                              }
                            },
                      child: Text(widget.isAdminMode ? 'SAVE STORE LOCATION' : 'CONFIRM ADDRESS'),
                    ),
                  ],
                ),
              ),
            ),
            
          if ((widget.isPickerMode || widget.isAdminMode) && _selectedLocation == null)
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
