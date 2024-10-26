import 'dart:convert';
import 'dart:io';
import 'package:tdlogistic_v2/customer/data/models/calculate_fee_payload.dart';
import '../models/order_model.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:async';

class OrderRepository {
  final String baseUrl = 'https://api.tdlogistics.net.vn/v3';

  Future<Map<String, dynamic>> getOrders(String token,
      {String status = "", int page = 1}) async {
    try {
      final url = Uri.parse('$baseUrl/order/search');
      final headers = {
        'Content-Type': 'application/json',
        "authorization": "Bearer $token"
      };

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(
          {
            "addition": {"sort": [], "page": page, "size": status == "PROCESSING"?100: 3, "group": []},
            "criteria": [
              {
                "field": "statusCode",
                "operator": (status == "CANCEL" ? "~" : "="),
                "value": status
              }
            ]
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
          "data": responseData["data"],
        };
      }
    } catch (error) {
      print("Error getting orders: ${error.toString()}");
      return {"success": false, "message": error.toString(), "data": null};
    }
  }

  Future<Map<String, dynamic>> getOrderById(String id, String token) async {
    try {
      final url = Uri.parse('$baseUrl/order/search');
      final headers = {
        'Content-Type': 'application/json',
        "authorization": "Bearer $token"
      };

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(
          {
            "addition": {"sort": [], "page": 1, "size": 5, "group": []},
            "criteria": [
              {"field": "id", "operator": "=", "value": id}
            ]
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
          "data": responseData["data"],
        };
      }
    } catch (error) {
      print("Error getting orders: ${error.toString()}");
      return {"success": false, "message": error.toString(), "data": null};
    }
  }

  Future<Map<String, dynamic>> getOrderImageById(
      String id, String token) async {
    try {
      final url = Uri.parse('$baseUrl/order/image/download?fileId=$id');
      final headers = {
        'Content-Type': 'application/json',
        "authorization": "Bearer $token"
      };
      final response = await http.get(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        return {
          'success': true,
          'data': bytes,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to load image: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error getting image: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<dynamic> calculateFee(CalculateFeePayload payload) async {
    try {
      final url = Uri.parse('$baseUrl/order/fee/calculate');
      final headers = {'Content-Type': 'application/json'};

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(payload.toJson()), // Chuyển payload sang JSON
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
      print(error.toString());
      return {
        "success": false,
        "message": error.toString(),
        "data": null,
      };
    }
  }

  Future<Order> createOrder(Order order) async {
    // Implement API call to create order
    return order;
  }

  Future<Map<String, dynamic>> updateImage(
      String id, List<File> info, String type, String token) async {
    var url = Uri.parse("$baseUrl/order/image/upload?orderId=$id&type=$type");
    var request = http.MultipartRequest("PUT", url);
    for (var i = 0; i < info.length; i++) {
      var mimeTypeData =
          lookupMimeType(info[i].path, headerBytes: [0xFF, 0xD8])!
              .split('/');
      var file = await http.MultipartFile.fromPath('file', info[i].path,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
      request.files.add(file);
    }
    request.headers['Content-Type'] = "multipart/form-data";
    request.headers["authorization"] = "Bearer $token";

    try {
      var streamResponse = await request.send();
      var response = await http.Response.fromStream(streamResponse);
      if (response.statusCode == 413) {
        return {'success': false, 'message': "Reached max size"};
      }

      final decodedResponse = utf8.decode(response.bodyBytes);
      var data = json.decode(decodedResponse);
      return {'success': data["success"], 'message': data["message"]};
    } catch (error) {
      print("Error updating images: $error");
      return {'success': false, 'message': error};
    }
  }
}
