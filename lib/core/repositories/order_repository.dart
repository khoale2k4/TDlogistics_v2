import 'dart:convert';
import 'dart:io';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/customer/data/models/calculate_fee_payload.dart';
import 'package:tdlogistic_v2/customer/data/models/cargo_insurance.dart';
import 'package:tdlogistic_v2/customer/data/models/create_order.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:async';

import 'package:tdlogistic_v2/customer/data/models/shipping_bill.dart';

class OrderRepository {
  final String baseUrl = baseUrll;

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
            "addition": {"sort": [], "page": page, "size": 10, "group": []},
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

      print(json.encode(
        {
          "addition": {"sort": [], "page": page, "size": 10, "group": []},
          "criteria": [
            {
              "field": "statusCode",
              "operator": (status == "CANCEL" ? "~" : "="),
              "value": status
            }
          ]
        },
      ));

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

  Future<Map<String, dynamic>> getOrderImageById(String id, String token,
      {bool isSign = false}) async {
    try {
      final url = Uri.parse(
          '$baseUrl/order/${isSign ? "signature" : "image"}/download?fileId=$id');
      final headers = {
        'Content-Type': 'application/json',
        "authorization": "Bearer $token"
      };
      print(url);
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

  Future<dynamic> calculateFee(String token, CalculateFeePayLoad payload) async {
    try {
      final url = Uri.parse('$baseUrl/order/fee/calculate');
      final headers = {'Content-Type': 'application/json'
      , "authorization": "Bearer $token"};

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(payload.toJson()), // Chuyển payload sang JSON
      );
      print(payload.toJson());

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

  Future<Map<String, dynamic>> createOrder(
      String token,
      CreateOrderObject order,
      List<File> files,
      CargoInsurance? cargoInsurance) async {
    try {
      final url = Uri.parse('$baseUrl/order/create');

      final request = http.MultipartRequest('POST', url)
        ..headers['authorization'] = 'Bearer $token';
      Map<String, String> formFields = {
        'data': json.encode(order.toJson()),
      };

      if (cargoInsurance != null) {
        // Giải mã chuỗi JSON hiện tại thành một đối tượng map
        Map<String, dynamic> dataMap = json.decode(formFields['data']!);

        // Thêm dữ liệu của cargoInsurance vào map
        dataMap['cargoInsurance'] = cargoInsurance.toJson();

        // Mã hóa lại thành JSON và gán vào trường 'data'
        formFields['data'] = json.encode(dataMap);
      }

      request.fields.addAll(formFields);
      for (var i = 0; i < files.length; i++) {
        var mimeTypeData =
            lookupMimeType(files[i].path, headerBytes: [0xFF, 0xD8])!
                .split('/');
        var file = await http.MultipartFile.fromPath('file', files[i].path,
            contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
        request.files.add(file);
      }

      print(request.fields);
      print(request.files);

      // Gửi request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print(response.body);

      final responseData = json.decode(response.body);
      print(responseData);
      if (response.statusCode == 201) {
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
      print("Error creating order: ${error.toString()}");
      return {"success": false, "message": error.toString(), "data": null};
    }
  }

  Future<Map<String, dynamic>> updateImage(
      String id, List<File> info, String type, String token,
      {bool isSign = false}) async {
    var url = Uri.parse(
        "$baseUrl/order/${isSign ? "signature" : "image"}/upload?orderId=$id&type=$type");
    var request = http.MultipartRequest("PUT", url);
    for (var i = 0; i < info.length; i++) {
      var mimeTypeData =
          lookupMimeType(info[i].path, headerBytes: [0xFF, 0xD8])!.split('/');
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
        return {'success': false, 'message': "Vượt quá dung lượng ảnh tối đa!"};
      }

      final decodedResponse = utf8.decode(response.bodyBytes);
      var data = json.decode(decodedResponse);
      return {'success': data["success"], 'message': data["message"]};
    } catch (error) {
      print("Error updating images: $error");
      return {'success': false, 'message': error};
    }
  }

  Future<Map<String, dynamic>> deleteFile(String id, String token,
      {bool isSign = false}) async {
    try {
      final url = Uri.parse("$baseUrl/order/image/delete/$id");
      final headers = {
        'Content-Type': 'application/json',
        "authorization": "Bearer $token"
      };
      print(url);

      final response = await http.delete(
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
          "data": responseData["data"],
        };
      }
    } catch (error) {
      print("Lỗi khi xoá ảnh: ${error.toString()}");
      return {
        "success": false,
        "message": error.toString(),
        "data": null,
      };
    }
  }

  Future<Map<String, dynamic>> createShippingBill(
      String token, ShippingBill sb) async {
    try {
      final url = Uri.parse('$baseUrl/shipping_bill/create');
      final headers = {
        'Content-Type': 'application/json',
        "authorization": "Bearer $token"
      };
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(sb.toJson()),
      );
      print(response.body);
      final responseData = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 210) {
        return {
          'success': true,
          'message': responseData["message"],
          'data': responseData["data"],
        };
      } else {
        return {
          'success': false,
          'message': responseData["message"],
          'data': null
        };
      }
    } catch (error) {
      print("Error creating shipping bill: ${error.toString()}");
      return {"success": false, "message": error.toString(), "data": null};
    }
  }

  Future<Map<String, dynamic>> getShippingBill(String token) async {
    try {
      final url = Uri.parse('$baseUrl/shipping_bill/customer/get');
      final headers = {
        'Content-Type': 'application/json',
        "authorization": "Bearer $token"
      };
      final response = await http.get(
        url,
        headers: headers,
      );
      final responseData = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 210) {
        return {
          'success': true,
          'message': responseData["message"],
          'data': responseData["data"],
        };
      } else {
        return {
          'success': false,
          'message': responseData["message"],
          'data': null
        };
      }
    } catch (error) {
      print("Error getting shipping bill: ${error.toString()}");
      return {"success": false, "message": error.toString(), "data": null};
    }
  }

  Future<Map<String, dynamic>> getShipperOrders(String token,String id) async {
    try {
      final url = Uri.parse('$baseUrl/order/shipper/get/$id');
      final headers = {
        'Content-Type': 'application/json',
        "authorization": "Bearer $token"
      };
      final response = await http.get(
        url,
        headers: headers,
      );

      final responseData = json.decode(response.body);
      print(responseData);
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
      print("Error getting shipper orders: ${error.toString()}");
      return {"success": false, "message": error.toString(), "data": null};
    }
  }
}
