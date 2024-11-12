import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:location/location.dart';
import 'package:tdlogistic_v2/core/constant.dart';

class Map2Markers extends StatefulWidget {
  final String startAddress;
  final String endAddress;

  const Map2Markers({
    Key? key,
    required this.startAddress,
    required this.endAddress,
  }) : super(key: key);

  @override
  _Map2MarkersState createState() => _Map2MarkersState();
}

class _Map2MarkersState extends State<Map2Markers>
    with SingleTickerProviderStateMixin {
  late GoogleMapController mapController;
  LatLng? _startLatLng;
  LatLng? _endLatLng;
  List<LatLng> _routePoints = [];
  double _currentZoom = 12.0;

  final String _apiKey =
      ggApiKey; // Thay bằng API Key của bạn

  Future<void> _initializeRoute() async {
    _startLatLng = await _getLatLngFromAddress(widget.startAddress);
    _endLatLng = await _getLatLngFromAddress(widget.endAddress);

    if (_startLatLng != null && _endLatLng != null) {
      _routePoints = await _getRoutePoints(_startLatLng!, _endLatLng!);
    }

    setState(() {});
  }

  Future<LatLng?> _getLatLngFromAddress(String address) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$_apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        return LatLng(location['lat'], location['lng']);
      }
    }
    return null;
  }

  Future<List<LatLng>> _getRoutePoints(LatLng start, LatLng end) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?origin=${start.latitude},${start.longitude}&destination=${end.latitude},${end.longitude}&key=$_apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        List<LatLng> routePoints = [];
        for (var step in data['routes'][0]['legs'][0]['steps']) {
          final startLat = step['start_location']['lat'];
          final startLng = step['start_location']['lng'];
          final endLat = step['end_location']['lat'];
          final endLng = step['end_location']['lng'];
          routePoints.add(LatLng(startLat, startLng));
          routePoints.add(LatLng(endLat, endLng));
        }
        return routePoints;
      }
    }
    return [];
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _zoomIn() {
    setState(() {
      _currentZoom += 1;
    });
    mapController.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    setState(() {
      _currentZoom -= 1;
    });
    mapController.animateCamera(CameraUpdate.zoomOut());
  }

  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _initializeRoute();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleLocationPanel() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  final Location _location = Location();
  Future<void> _goToMyLocation() async {
    var currentLocation = await _location.getLocation();
    print("smth");
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
          zoom: 15,
        ),
      ),
    );
  }

  void _moveToLocation(LatLng location) {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: location,
          zoom: 15,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
          zoomControlsEnabled: false,
            initialCameraPosition: CameraPosition(
              target: _startLatLng??const LatLng(10.762622, 106.660172),
              zoom: _currentZoom,
            ),
            markers: {
              if (_startLatLng != null)
                Marker(
                  markerId: const MarkerId("start"),
                  position: _startLatLng??const LatLng(10.762622, 106.660172),
                  infoWindow: const InfoWindow(title: "Điểm đi"),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                ),
              if (_endLatLng != null)
                Marker(
                  markerId: const MarkerId("end"),
                  position: _endLatLng??const LatLng(10.762622, 106.660172),
                  infoWindow: const InfoWindow(title: "Điểm đến"),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                ),
            },
            polylines: {
              Polyline(
                polylineId: const PolylineId("route"),
                points: _routePoints,
                color: Colors.blue,
                width: 5,
              ),
            },
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _goToMyLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () => {Navigator.of(context).pop()},
                icon: const Icon(
                  Icons.keyboard_return,
                  size: 30, color: Colors.black
                ),
              ),
            ),
          ),

          // Panel điểm đi và điểm đến
          Positioned(
            top: 40,
            left: 90,
            right: 16,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            // Nút mở rộng/thu nhỏ
            InkWell(
              onTap: _toggleLocationPanel,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Chi tiết hành trình',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Icon(_isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            ),
            
            // Chi tiết điểm đi/đến
            if (_isExpanded) ...[
              ListTile(
                leading: const Icon(Icons.location_on, color: Colors.blue),
                title: Text(widget.startAddress),
                onTap: () => _moveToLocation(
                    _startLatLng ?? const LatLng(10.762622, 106.660172)),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.location_on, color: Colors.red),
                title: Text(widget.endAddress),
                onTap: () => _moveToLocation(
                    _endLatLng ?? const LatLng(10.762622, 106.660172)),
              ),
            ],
          ],
        ),
      ),
    );
              },
            ),
          ),
        ],
      ),
    );
  }
}
