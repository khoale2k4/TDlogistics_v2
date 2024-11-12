import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart';
import 'package:tdlogistic_v2/core/constant.dart';

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
  List<dynamic> _startSuggestions = [];
  List<dynamic> _endSuggestions = [];
  final LatLng _currentPosition =
      const LatLng(10.8231, 106.6297); // Tọa độ khởi tạo
  LatLng? _startLocation;
  LatLng? _endLocation;
  final Set<Marker> _markers = {}; // Lưu trữ các marker
  Set<Polyline> _polylines = {}; // Lưu trữ đường đi
  final String _apiKey =
      ggApiKey; // Thay bằng API Key của bạn

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Gọi Places API để lấy gợi ý địa chỉ cho điểm bắt đầu hoặc điểm kết thúc
  Future<void> _getSearchSuggestions(String query, bool isStart) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        if (isStart) {
          _startSuggestions = data['predictions'];
        } else {
          _endSuggestions = data['predictions'];
        }
      });
    } else {
      print("Error fetching suggestions: ${response.body}");
    }
  }

  // Chuyển đổi địa chỉ sang tọa độ và thêm marker
  Future<void> _moveToLocation(String placeId, bool isStart) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final location = data['result']['geometry']['location'];
      final latLng = LatLng(location['lat'], location['lng']);

      mapController.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 14.0),
      );
      setState(() {
        if (isStart) {
          _startLocation = latLng;
          _startSuggestions = [];
          _startSearchController.clear();
          _markers.add(Marker(
            markerId: const MarkerId('start'),
            position: latLng,
            infoWindow: const InfoWindow(title: 'Điểm bắt đầu'),
          ));
        } else {
          _endLocation = latLng;
          _endSuggestions = [];
          _endSearchController.clear();
          _markers.add(Marker(
            markerId: const MarkerId('end'),
            position: latLng,
            infoWindow: const InfoWindow(title: 'Điểm đến'),
          ));
        }
      });

      // Nếu cả hai điểm đã được chọn, tính toán và vẽ đường đi
      if (_startLocation != null && _endLocation != null) {
        _calculateRoute();
      }
    }
  }

// Thêm vào phần khai báo biến
  bool _isLoading = false; // Để hiển thị loading indicator
  String? _error; // Để hiển thị lỗi nếu có

// Cải thiện hàm _calculateRoute
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
              color: Colors.blue,
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
            top: 20,
            left: 15,
            right: 15,
            child: Column(
              children: [
                _buildSearchField(
                  controller: _startSearchController,
                  hintText: "Điểm bắt đầu",
                  isStart: true,
                  suggestions: _startSuggestions,
                ),
                const SizedBox(height: 10),
                _buildSearchField(
                  controller: _endSearchController,
                  hintText: "Điểm đến",
                  isStart: false,
                  suggestions: _endSuggestions,
                ),
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.white,
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField({
    required TextEditingController controller,
    required String hintText,
    required bool isStart,
    required List<dynamic> suggestions,
  }) {
    return Column(
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (query) {
            if (query.isNotEmpty) {
              _getSearchSuggestions(query, isStart);
            } else {
              setState(() {
                if (isStart) {
                  _startSuggestions = [];
                } else {
                  _endSuggestions = [];
                }
              });
            }
          },
        ),
        const SizedBox(height: 5),
        if (suggestions.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(suggestions[index]['description']),
                  onTap: () {
                    _moveToLocation(suggestions[index]['place_id'], isStart);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
