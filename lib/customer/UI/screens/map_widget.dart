import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key}) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late GoogleMapController mapController;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchSuggestions = [];
  LatLng _currentPosition = const LatLng(10.8231, 106.6297); // Tọa độ khởi tạo
  final String _apiKey = "AIzaSyB1D4XCGPDidtXUwOw1K-gQ8VPB2c4IxC8"; // Thay bằng API Key của bạn

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Gọi Places API để lấy gợi ý địa chỉ
  Future<void> _getSearchSuggestions(String query) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _searchSuggestions = data['predictions'];
      });
    } else {
      print("Error fetching suggestions: ${response.body}");
    }
  }

  // Chuyển đổi địa chỉ sang tọa độ và di chuyển camera đến đó
  Future<void> _moveToLocation(String placeId) async {
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
        _currentPosition = latLng;
        _searchSuggestions = [];
        _searchController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Map"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 12.0,
            ),
          ),
          Positioned(
            top: 20,
            left: 15,
            right: 15,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Nhập địa điểm",
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
                      _getSearchSuggestions(query);
                    } else {
                      setState(() {
                        _searchSuggestions = [];
                      });
                    }
                  },
                ),
                const SizedBox(height: 5),
                Container(decoration: BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),color: Colors.white),child:
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _searchSuggestions.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_searchSuggestions[index]['description']),
                      onTap: () {
                        _moveToLocation(_searchSuggestions[index]['place_id']);
                      },
                    );
                  },
                ),),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
