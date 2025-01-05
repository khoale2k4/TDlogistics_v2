import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:tdlogistic_v2/core/constant.dart';

class MapScreen extends StatefulWidget {
  final LatLng startLocation;
  final LatLng endLocation;

  const MapScreen(
      {Key? key, required this.startLocation, required this.endLocation})
      : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  String _distance = "";
  String _duration = "";

  @override
  void initState() {
    super.initState();
    _fetchRoute();
  }

  Future<void> _fetchRoute() async {
    try {
      final String url =
          "https://maps.googleapis.com/maps/api/directions/json?origin=${widget.startLocation.latitude},${widget.startLocation.longitude}&destination=${widget.endLocation.latitude},${widget.endLocation.longitude}&key=${ggApiKey}";
      print(url);
      final response = await http.get(Uri.parse(url));
      print(response);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);

        if (data["routes"].isNotEmpty) {
          final route = data["routes"][0];
          final legs = route["legs"][0];

          // Lấy khoảng cách và thời gian
          setState(() {
            _distance = legs["distance"]["text"];
            _duration = legs["duration"]["text"];
          });

          // Vẽ polyline
          final points = route["overview_polyline"]["points"];
          print(points);
          _setPolyline(points);

          // Thêm marker
          _setMarkers();

          // Cập nhật camera để bao phủ cả hai điểm
          _updateCameraBounds();
        }
      } else {
        print("Failed to fetch directions.");
      }
    } catch (error) {
      print("Error fetching route: ${error.toString()}");
    }
  }

  void _setPolyline(String encoded) {
    try {
      final List<LatLng> points = _decodePolyline(encoded);
      setState(() {
        _polylines.add(Polyline(
          polylineId: PolylineId("route"),
          points: points,
          color: Colors.blue,
          width: 5,
        ));
      });
    } catch (error) {
      print("Polylines: ${error.toString()}");
    }
  }

  void _setMarkers() {
    try {
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId("start"),
          position: widget.startLocation,
          infoWindow: InfoWindow(title: "Nơi gửi"),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ));
        _markers.add(Marker(
          markerId: MarkerId("end"),
          position: widget.endLocation,
          infoWindow: InfoWindow(title: "Nơi nhận"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ));
      });
    } catch (error) {
      print("Lỗi set markers: ${error.toString()}");
    }
  }

  void _updateCameraBounds() {
    try {
      final double southLat =
          widget.startLocation.latitude < widget.endLocation.latitude
              ? widget.startLocation.latitude
              : widget.endLocation.latitude;
      final double northLat =
          widget.startLocation.latitude > widget.endLocation.latitude
              ? widget.startLocation.latitude
              : widget.endLocation.latitude;

      final double westLng =
          widget.startLocation.longitude < widget.endLocation.longitude
              ? widget.startLocation.longitude
              : widget.endLocation.longitude;
      final double eastLng =
          widget.startLocation.longitude > widget.endLocation.longitude
              ? widget.startLocation.longitude
              : widget.endLocation.longitude;

      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(southLat, westLng),
        northeast: LatLng(northLat, eastLng),
      );

      _mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    } catch (error) {
      print("Lỗi camera: ${error.toString()}");
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    try {
      List<LatLng> poly = [];
      int index = 0, len = encoded.length;
      int lat = 0, lng = 0;

      while (index < len) {
        int b, shift = 0, result = 0;
        do {
          b = encoded.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20);
        int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lat += dlat;

        shift = 0;
        result = 0;
        do {
          b = encoded.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20);
        int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lng += dlng;

        poly.add(LatLng(lat / 1E5, lng / 1E5));
      }

      return poly;
    } catch (error) {
      print("Lỗi decode route: ${error.toString()}");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Container(
        //   height: 300,
        //   child: GoogleMap(
        //     initialCameraPosition: CameraPosition(
        //       target: widget.startLocation,
        //       zoom: 12,
        //     ),
        //     onMapCreated: (controller) {
        //       _mapController = controller;
        //     },
        //     polylines: _polylines,
        //     markers: _markers,
        //     myLocationButtonEnabled: false,
        //   ),
        // ),
        if (_distance.isNotEmpty && _duration.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("$_distance - $_duration"),
          ),
      ],
    );
  }
}
