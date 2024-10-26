import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tdlogistic_v2/shipper/data/models/task.dart';

class TaskRepository {
  final String baseUrl = 'https://api.tdlogistics.net.vn/v3';

  Future<dynamic> getTasks(String token, String status, {int page = 1}) async {
    try {
      final url = Uri.parse('$baseUrl/task/shipper/search');
      final headers = {
        'Content-Type': 'application/json',
        "authorization": "Bearer $token"
      };

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(
          {
            "addition": {"sort": [], "page": page, "size": 3, "group": []},
            "criteria": [
              if (status != "")
                {"field": "order.statusCode", "operator": "=", "value": status},
            ],
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
      print("Error getting tasks: ${error.toString()}");
      return {"success": false, "message": error.toString(), "data": null};
    }
  }

  Future<dynamic> acceptTasks(String token, String orderId) async {
    try {
      final url = Uri.parse('$baseUrl/sending_order_request/accept/$orderId');
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
        };
      } else {
        return {
          "success": false,
          "message": responseData["message"],
        };
      }
    } catch (error) {
      print("Error getting tasks: ${error.toString()}");
      return {"success": false, "message": error.toString()};
    }
  }
}
