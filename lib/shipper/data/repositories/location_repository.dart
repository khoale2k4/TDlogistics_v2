import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/shipper/data/models/task.dart';

class LocationRepository {
  final String baseUrl = baseUrll;

  Future<Map<String, dynamic>> getRoute(String token, String orderId) async {
    try {
      final url = Uri.parse('$baseUrl/task/shipper/journey/get/$orderId');
      final headers = {
        'Content-Type': 'application/json',
        "authorization": "Bearer $token"
      };

      final response = await http.get(
        url,
        headers: headers,
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": responseData["message"],
          "data": responseData["data"],
        };
      } else {
        return {
          "success": false,
          "message": responseData["message"],
          "data": null,
        };
      }
    } catch (error) {
      print("Error getting locations: ${error.toString()}");
      return {"success": false, "message": error.toString(), "data": null};
    }
  }

  Future<Map<String, dynamic>> addRoute(String token, String orderId, double lat, double lng) async {
    try {
      final url = Uri.parse('$baseUrl/task/shipper/journey/get/$orderId');
      final headers = {
        'Content-Type': 'application/json',
        "authorization": "Bearer $token"
      };

      final response = await http.post (
        url,
        headers: headers,
        
        body: json.encode(
          {
            "lat" : lat,
            "lng" : lng
          },
        ),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": responseData["message"],
          "data": responseData["data"],
        };
      } else {
        return {
          "success": false,
          "message": responseData["message"],
          "data": null,
        };
      }
    } catch (error) {
      print("Error adding location: ${error.toString()}");
      return {"success": false, "message": error.toString(), "data": null};
    }
  }
}