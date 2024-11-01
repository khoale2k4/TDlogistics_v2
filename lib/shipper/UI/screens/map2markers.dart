import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';

class Map2Markers extends StatefulWidget {
  final String endAddress;

  const Map2Markers({
    Key? key,
    required this.endAddress,
  }) : super(key: key);

  @override
  _Map2MarkersState createState() => _Map2MarkersState();
}

class _Map2MarkersState extends State<Map2Markers> with SingleTickerProviderStateMixin {
  late GoogleMapController mapController;
  LatLng? _startLatLng;
  LatLng? _endLatLng;
  List<LatLng> _routePoints = [];
  double _currentZoom = 12.0;

  final String _apiKey = "AIzaSyB1D4XCGPDidtXUwOw1K-gQ8VPB2c4IxC8"; // Thay bằng API Key của bạn

  Future<void> _initializeRoute() async {
    // Lấy vị trí hiện tại của người dùng
    final position = await _getCurrentLocation();
    _startLatLng = LatLng(position.latitude, position.longitude);

    _endLatLng = await _getLatLngFromAddress(widget.endAddress);
    if (_startLatLng != null && _endLatLng != null) {
      _routePoints = await _getRoutePoints(_startLatLng!, _endLatLng!);
    }

    setState(() {});
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Kiểm tra quyền và bật dịch vụ
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Dịch vụ định vị không bật');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Quyền định vị bị từ chối');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Quyền định vị bị từ chối vĩnh viễn');
    }

    // Lấy vị trí hiện tại
    return await Geolocator.getCurrentPosition();
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
  void initState() {
    super.initState();
    _initializeRoute();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_startLatLng != null)
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _startLatLng!,
                zoom: _currentZoom,
              ),
              markers: {
                if (_startLatLng != null)
                  Marker(
                    markerId: const MarkerId("start"),
                    position: _startLatLng!,
                    infoWindow: const InfoWindow(title: "Vị trí của bạn"),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                  ),
                if (_endLatLng != null)
                  Marker(
                    markerId: const MarkerId("end"),
                    position: _endLatLng!,
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
                icon: const Icon(Icons.keyboard_return, size: 30, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
