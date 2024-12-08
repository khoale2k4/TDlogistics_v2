import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:tdlogistic_v2/core/constant.dart';
import 'dart:async';

import 'package:tdlogistic_v2/customer/data/models/favorite_location.dart';

class LocationRepository {
  final String baseUrl = baseUrll;

  Future<Map<String, dynamic>> getLocations(String token) async {
    try {
      Uri url = Uri.parse('$baseUrl/order_location/get');
      final headers = {
        'Content-Type': 'application/json',
        "authorization": "Bearer $token"
      };
      var response = await http.get(
        url,
        headers: headers,
      );
      var responseData = json.decode(response.body);
      List<Location> locations = [];
      List<FavoriteLocation> favLocations = [];

      if (response.statusCode >= 200 && response.statusCode <= 210) {
        for (dynamic location in responseData["data"]) {
          locations.add(Location.fromJson(location));
        }
      } else {
        return {
          "success": false,
          "message": "Lấy địa điểm không thành công",
          "data": null
        };
      }

      url = Uri.parse('$baseUrl/favorite_order_location/get');
      response = await http.get(
        url,
        headers: headers,
      );
      responseData = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode <= 210) {
        for (dynamic location in responseData["data"]) {
          favLocations.add(FavoriteLocation.fromJson(location));
        }
      } else {
        return {
          "success": false,
          "message": "Lấy địa điểm ưa thích không thành công",
          "data": null
        };
      }

      return {
        "success": true,
        "message": "Lấy các địa điểm thành công",
        "data": [locations, favLocations]
      };
    } catch (error) {
      print("Lỗi khi lấy địa điểm: $error");
      return {
        "success": false,
        "message": error.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> createLocations(
      String token, String type, double lat, double lng) async {
    try {
      Uri url = Uri.parse('$baseUrl/order_location/create');
      final headers = {
        'Content-Type': 'application/json',
        "authorization": "Bearer $token"
      };
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(
          {"name": type, "lat": lat, "lng": lng},
        ),
      );
      final responseData = json.decode(response.body);
      print(responseData);
      if (response.statusCode >= 200 && response.statusCode <= 210) {
        return {
          "success": true,
          "message": "Tạo địa điểm thành công",
          "data": responseData
        };
      }
      return {
        "success": false,
        "message": "Tạo địa điểm thất bại",
        "data": null
      };
    } catch (error) {
      print("Lỗi khi lấy địa điểm: $error");
      return {
        "success": false,
        "message": error.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> createFavLocations(String token, String des,
      String name, String phone, double lat, double lng) async {
    try {
      Uri url = Uri.parse('$baseUrl/favorite_order_location/create');
      final headers = {
        'Content-Type': 'application/json',
        "authorization": "Bearer $token"
      };
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(
          {
            "description": des,
            "name": name,
            "phoneNumber": phone,
            "lat": lat,
            "lng": lng,
          },
        ),
      );
      print(json.encode({
        "description": des,
        "name": name,
        "phoneNumber": phone,
        "lat": lat,
        "lng": lng,
      }));
      final responseData = json.decode(response.body);
      print(responseData);
      if (response.statusCode >= 200 && response.statusCode <= 210) {
        return {
          "success": true,
          "message": "Tạo địa điểm thành công",
          "data": responseData
        };
      }
      return {
        "success": false,
        "message": "Tạo địa điểm thất bại",
        "data": null
      };
    } catch (error) {
      print("Lỗi khi lấy địa điểm: $error");
      return {
        "success": false,
        "message": error.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getPositions(
      String token, String orderId) async {
    try {
      Uri url = Uri.parse('$baseUrl/order/shipper/current_journey/$orderId');
      final headers = {
        'Content-Type': 'application/json',
        "authorization": "Bearer $token"
      };
      print(url);
      var response = await http.get(
        url,
        headers: headers,
      );
      final responseData = json.decode(response.body);
      print(responseData);
      if (response.statusCode >= 200 && response.statusCode <= 210) {
        List<LatLng> routePoints = [];
        for (var point in responseData["data"]) {
          if(point[0] == null || point[1] == null) continue;
          double lat =  point[0].toDouble();
          double lng = point[1].toDouble();
          routePoints.add(LatLng(lat, lng));
        }
        return {
          "success": true,
          "message": "Lấy địa điểm thành công",
          "data": routePoints
        };
      } else {
        return {
          "success": false,
          "message": "Lấy địa điểm không thành công",
          "data": null
        };
      }
    } catch (error) {
      print("Lỗi khi lấy địa điểm: $error");
      return {
        "success": false,
        "message": error.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> updateLocation(
      String token, Location location) async {
    try {
      Uri url = Uri.parse('$baseUrl/order_location/update/${location.id}');
      print(url);
      final headers = {
        'Content-Type': 'application/json',
        "authorization": "Bearer $token"
      };
      var response = await http.put(
        url,
        headers: headers,
        body: json.encode(
          location.toJson(),
        ),
      );
      final responseData = json.decode(response.body);
      print(responseData);
      if (response.statusCode >= 200 && response.statusCode <= 210) {
        return {
          "success": true,
          "message": "Cập nhật địa điểm thành công",
          "data": responseData
        };
      } else {
        return {
          "success": false,
          "message": "Cập nhật địa điểm không thành công",
          "data": null
        };
      }
    } catch (error) {
      print("Lỗi khi lấy địa điểm: $error");
      return {
        "success": false,
        "message": error.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> updateFavoriteLocation(
      String token, FavoriteLocation location) async {
    try {
      Uri url = Uri.parse('$baseUrl/favorite_order_location/update/${location.id}');
      final headers = {
        'Content-Type': 'application/json',
        "authorization": "Bearer $token"
      };
      var response = await http.put(
        url,
        headers: headers,
        body: json.encode(
          location.toJson(),
        ),
      );
      print(json.encode(
          location.toJson(),
        ),);
      final responseData = json.decode(response.body);
      print(responseData);
      if (response.statusCode >= 200 && response.statusCode <= 210) {
        return {
          "success": true,
          "message": "Cập nhật địa điểm thành công",
          "data": responseData
        };
      } else {
        return {
          "success": false,
          "message": "Cập nhật địa điểm không thành công",
          "data": null
        };
      }
    } catch (error) {
      print("Lỗi khi lấy địa điểm: $error");
      return {
        "success": false,
        "message": error.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> deleteLocation(
      String token, String locationId, {bool isFav = false}) async {
    try {
      Uri url = Uri.parse('$baseUrl/${isFav?"favorite_order_location":"order_location"}/delete/$locationId');
      final headers = {
        'Content-Type': 'application/json',
        "authorization": "Bearer $token"
      };
      var response = await http.delete(
        url,
        headers: headers,
      );
      final responseData = json.decode(response.body);
      print(responseData);
      if (response.statusCode >= 200 && response.statusCode <= 210) {
        return {
          "success": true,
          "message": "Xoá địa điểm thành công",
          "data": responseData
        };
      } else {
        return {
          "success": false,
          "message": "Xoá địa điểm không thành công",
          "data": null
        };
      }
    } catch (error) {
      print("Lỗi khi xoá địa điểm: $error");
      return {
        "success": false,
        "message": error.toString(),
      };
    }
  }

}
