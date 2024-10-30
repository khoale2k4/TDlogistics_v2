import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

class _Map2MarkersState extends State<Map2Markers> {
  late GoogleMapController mapController;
  LatLng? _startLatLng = LatLng(10.762622, 106.660172);
  LatLng? _endLatLng = LatLng(10.762622, 106.660172);
  List<LatLng> _routePoints = [];
  double _currentZoom = 12.0;

  final String _apiKey = "AIzaSyB1D4XCGPDidtXUwOw1K-gQ8VPB2c4IxC8";  // Thay bằng API Key của bạn

  @override
  void initState() {
    super.initState();
    _initializeRoute();
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xem tuyến đường'),
      ),
      body: _startLatLng == null || _endLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _startLatLng!,
                    zoom: _currentZoom,
                  ),
                  markers: {
                    if(_startLatLng != null) Marker(
                      markerId: MarkerId("start"),
                      position: _startLatLng!,
                      infoWindow: InfoWindow(title: "Start Position"),
                    ),
                    if(_endLatLng != null)Marker(
                      markerId: MarkerId("end"),
                      position: _endLatLng!,
                      infoWindow: InfoWindow(title: "End Position"),
                    ),
                  },
                  polylines: {
                    Polyline(
                      polylineId: PolylineId("route"),
                      points: _routePoints,
                      color: Colors.blue,
                      width: 5,
                    ),
                  },
                ),
              ],
            ),
    );
  }
}
