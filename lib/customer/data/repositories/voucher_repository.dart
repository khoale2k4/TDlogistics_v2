import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tdlogistic_v2/core/constant.dart';
import 'dart:async';
import 'package:tdlogistic_v2/customer/data/models/voucher.dart';

class VoucherRepository {
  final String baseUrl = baseUrll;

  Future<Map<String, dynamic>> getVouchers(
      String token, int page, int size) async {
    try {
      Uri url = Uri.parse('$baseUrl/voucher/get?page=$page&size=$size');
      final headers = {
        'Content-Type': 'application/json',
        "authorization": "Bearer $token"
      };
      var response = await http.get(
        url,
        headers: headers,
      );
      var responseData = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode <= 210) {
        List<Voucher> vouchers = [];
        for(final voucher in responseData["data"]) {
          vouchers.add(Voucher.fromJson(voucher));
        }
        return {
          "success": true,
          "message": "Lấy các phiếu giảm giá thành công",
          "data": vouchers
        };
      } else {
        print(responseData);
        return {
          "success": false,
          "message": "Lấy các phiếu giảm giá không thành công",
          "data": null
        };
      }
    } catch (error) {
      print("Lỗi khi lấy phiếu giảm giá: $error");
      return {
        "success": false,
        "message": error.toString(),
      };
    }
  }
}
