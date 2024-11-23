import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/shipper/UI/widgets/search_bar.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late GoogleMapController mapController;
  final TextEditingController _startSearchController = TextEditingController();
  final TextEditingController _endSearchController = TextEditingController();
  final Location _location = Location();
  final LatLng _currentPosition =
      const LatLng(10.8231, 106.6297); // Tọa độ khởi tạo
  LatLng? _startLocation;
  LatLng? _endLocation;
  final Set<Marker> _markers = {}; // Lưu trữ các marker
  Set<Polyline> _polylines = {}; // Lưu trữ đường đi
  final String _apiKey = ggApiKey; // Thay bằng API Key của bạn

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _moveToLocation(String address, bool isStart) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        final latLng = LatLng(location['lat'], location['lng']);

        mapController.animateCamera(
          CameraUpdate.newLatLngZoom(latLng, 14.0),
        );

        setState(() {
          if (isStart) {
            _startLocation = latLng;
            _markers.add(Marker(
              markerId: const MarkerId('start'),
              position: latLng,
              infoWindow: const InfoWindow(title: 'Điểm bắt đầu'),
            ));
          } else {
            _endLocation = latLng;
            _markers.add(Marker(
              markerId: const MarkerId('end'),
              position: latLng,
              infoWindow: const InfoWindow(title: 'Điểm đến'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)

            ));
          }
        });

        // Nếu cả hai điểm đã được chọn, tính toán và vẽ đường đi
        if (_startLocation != null && _endLocation != null) {
          _calculateRoute();
        }
      } else {
        print("Không tìm thấy vị trí cho địa chỉ này.");
      }
    } else {
      print("Lỗi khi gọi API: ${response.statusCode}");
    }
  }

  bool _isLoading = false; 
  String? _error;

  Future<void> _calculateRoute() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (_startLocation == null || _endLocation == null) return;

      // Xóa polyline cũ trước khi vẽ mới
      _polylines.clear();

      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json?origin=${_startLocation!.latitude},${_startLocation!.longitude}&destination=${_endLocation!.latitude},${_endLocation!.longitude}&key=$_apiKey');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final List<LatLng> polylineCoordinates = [];

          // Lấy tất cả points từ route
          final points = PolylinePoints()
              .decodePolyline(data['routes'][0]['overview_polyline']['points']);

          // Chuyển đổi points thành LatLng
          for (var point in points) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          }

          setState(() {
            _polylines.add(Polyline(
              polylineId: const PolylineId('route'),
              color: mainColor,
              width: 5,
              points: polylineCoordinates,
            ));

            // Di chuyển camera để hiển thị toàn bộ route
            LatLngBounds bounds = LatLngBounds(
              southwest: _startLocation!,
              northeast: _endLocation!,
            );
            mapController
                .animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
          });
        } else {
          setState(() => _error = 'Không thể tìm được đường đi');
        }
      }
    } catch (e) {
      setState(() => _error = 'Đã xảy ra lỗi: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

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

  // Decode polyline từ Google Directions API
  List<LatLng> _decodePolyline(String poly) {
    var list = poly.codeUnits;
    var lList = <LatLng>[];
    int index = 0;
    int len = poly.length;
    int c = 0;

    do {
      var shift = 0;
      int result = 0;

      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << shift;
        shift += 5;
        index++;
      } while (c >= 0x20);
      int latChange = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));

      shift = 0;
      result = 0;

      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << shift;
        shift += 5;
        index++;
      } while (c >= 0x20);
      int lngChange = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));

      var lat = (latChange + (_currentPosition.latitude * 1E5).toInt()) / 1E5;
      var lng = (lngChange + (_currentPosition.longitude * 1E5).toInt()) / 1E5;
      lList.add(LatLng(lat, lng));
    } while (index < len);

    return lList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 12.0,
            ),
            markers: _markers,
            polylines: _polylines,
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
            top: 50,
            left: 15,
            right: 15,
            child: Column(
              children: [
                MySearchBar(
                  controller: _startSearchController,
                  labelText: "Điểm bắt đầu",
                  onTap: () {
                    _moveToLocation(_startSearchController.text, true);
                  },
                  onChanged: (){},
                  icon: const Icon(Icons.location_on, color: Colors.red),
                  onDelete: (){},
                ),
                const SizedBox(height: 10),
                MySearchBar(
                  controller: _endSearchController,
                  labelText: "Điểm đích",
                  onTap: () {
                    _moveToLocation(_endSearchController.text, false);
                  },
                  onChanged: (){},
                  icon: const Icon(Icons.location_on, color: Colors.blue),
                  onDelete: (){
                  },
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
