import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationTrackerService {
  List<String> taskIds = [];
  bool calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    double distanceInMeters = Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );

    return distanceInMeters > 2;
  }

  Future<void> startLocationTracking(String token) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // Define location settings with a distance filter of 10 meters
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter:
          10, // Minimum distance (in meters) before getting a new update
    );

    double curLat = 0;
    double curLng = 0;
    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        // Send the current position to the API every 10 seconds
        Timer.periodic(const Duration(seconds: 10), (Timer timer) async {
          if (calculateDistance(
              curLat, curLng, position.latitude, position.longitude)) {
            curLat = position.latitude;
            curLng = position.longitude;
            for (String taskIs in taskIds) {
              await _sendLocationToAPI(position.latitude, position.longitude, taskIs, token);
            }
          }
        });
      },
    );
  }

  void addTask(String taskId) {
    taskIds.add(taskId);
  }

  void changeToThisList(List<String> newTaskId){
    taskIds.clear();
    taskIds.addAll(newTaskId);
  }

  void removeTask(String taskId) {
    if (taskIds.contains(taskId)) {
      taskIds.remove(taskId);
    }
  }

  Future<void> _sendLocationToAPI(
      double latitude, double longitude, String taskIs, String token) async {
        print("Sending $taskIs's location: lat: $latitude, long: $longitude");
    return;
    final response = await http.post(
      Uri.parse('https://api.example.com/location'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      print('Location sent successfully');
    } else {
      print('Failed to send location');
    }
  }
}
