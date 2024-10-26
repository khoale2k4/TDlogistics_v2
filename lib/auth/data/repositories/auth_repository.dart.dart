import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthRepository {
  final String baseUrl = 'https://api.tdlogistics.net.vn/v3';

  AuthRepository();

  Future<Map<String, dynamic>> sendOTP(String email, String phone) async {
    try {
      final url = Uri.parse('$baseUrl/auth/customer/login');
      final headers = {'Content-Type': 'application/json'};
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({
          'phoneNumber': phone,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print(responseData);

        if (responseData["success"] == true) {
          print("OTP sent to $email, phone $phone");
          return {"success": true, "id": responseData["data"]["id"]};
        }
      } else {
        print("Error: ${response.statusCode} - ${response.reasonPhrase}");
      }
    } catch (error) {
      print("Exception: $error");
    }
    return {"success": false, "id": null};
  }

  Future<dynamic> otpVerification(String id, String otp) async {
    final url = Uri.parse('$baseUrl/auth/otp/verify');
    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(
      url,
      headers: headers,
      body: json.encode({
        'id': id,
        'otp': otp,
      }),
    );
    print(response.body);

    // Lấy giá trị của trường 'set-cookie'
    String? setCookie = response.headers['set-cookie'];

    // Kiểm tra nếu set-cookie tồn tại
    if (setCookie != null) {
      // Tìm vị trí của 'sid=' trong chuỗi set-cookie
      RegExp regExp = RegExp(r'sid=([^;]+)'); // Regex để tìm token sau 'sid='
      Match? match = regExp.firstMatch(setCookie);

      if (match != null) {
        // Lấy giá trị của sid
        String sidToken = match.group(1)!;
        return {
          "success": true,
          "message": jsonDecode(response.body)["message"],
          "data": await getUser(sidToken),
          "token": sidToken
        };
      } else {
        print('Không tìm thấy token sid');
      }
    } else {
      print('Không tìm thấy trường set-cookie');
    }
    return {
      "success": false,
      "message": jsonDecode(response.body)["message"],
      "data": null
    };
  }

  Future<User?> getUser(String token) async {
    try {
      Uri url = Uri.parse('$baseUrl/customer/');
      http.Response response =
          await http.get(url, headers: {"authorization": "Bearer $token"});
      dynamic responseData = jsonDecode(response.body);
      print(responseData);
      print(responseData["data"]);
      if(responseData["data"] == null) {
        url = Uri.parse('$baseUrl/staff/');
        response =
          await http.get(url, headers: {"authorization": "Bearer $token"});
      }
      responseData = jsonDecode(response.body);
      print(responseData);
      print(responseData["data"]);
      return User.fromJson(responseData["data"]);
    } catch (error) {
      print("error getting user info ${error.toString()}");
      return null;
    }
  }

  Future<void> logout() async {
    final url = Uri.parse('$baseUrl/logout');
    final response = await http.post(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to logout');
    }
  }

  Future<dynamic> staffLogin(String username, String password) async {
    final url = Uri.parse('$baseUrl/auth/staff/login');
    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(
      url,
      headers: headers,
      body: json.encode({
        "password": password,
        "username": username,
      }),
    );
    print(response.body);

    // Lấy giá trị của trường 'set-cookie'
    String? setCookie = response.headers['set-cookie'];

    // Kiểm tra nếu set-cookie tồn tại
    if (setCookie != null) {
      // Tìm vị trí của 'sid=' trong chuỗi set-cookie
      RegExp regExp = RegExp(r'sid=([^;]+)'); // Regex để tìm token sau 'sid='
      Match? match = regExp.firstMatch(setCookie);

      if (match != null) {
        // Lấy giá trị của sid
        String sidToken = match.group(1)!;
        return {
          "success": true,
          "message": jsonDecode(response.body)["message"],
          "data": User.fromJson(jsonDecode(response.body)["data"]),
          "token": sidToken
        };
      } else {
        print('Không tìm thấy token sid');
      }
    } else {
      print('Không tìm thấy trường set-cookie');
    }
    return {
      "success": false,
      "message": jsonDecode(response.body)["message"],
      "data": null
    };
  }
}
