import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:tdlogistic_v2/core/constant.dart';

Future<String?> convertLatLngToAddress(
    double latitude, double longitude) async {
  final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$ggApiKey');

  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data['status'] == 'OK' && data['results'].isNotEmpty) {
      // Trả về địa chỉ đầu tiên trong kết quả
      // print(jsonEncode(data['results'][0]));
      return data['results'][0]['formatted_address'];
    } else {
      print("Không tìm thấy địa chỉ.");
      return null;
    }
  } else {
    print("Yêu cầu thất bại với mã lỗi: ${response.statusCode}");
    return null;
  }
}

Future<Map<String, double>?> getLatLngFromAddress(String address) async {
  String apiKey = ggApiKey;
  final Uri url = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$apiKey');

  final response = await http.get(url);

  // Kiểm tra nếu yêu cầu thành công
  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    // Kiểm tra nếu có kết quả trả về từ API
    if (data['status'] == 'OK' && data['results'].isNotEmpty) {
      final location = data['results'][0]['geometry']['location'];
      final double lat = location['lat'];
      final double lng = location['lng'];

      // print("Tìm được địa chỉ!!!");
      return {'lat': lat, 'lng': lng};
    } else {
      print('Không tìm thấy tọa độ cho địa chỉ: $address');
      return null;
    }
  } else {
    print('Lỗi khi gửi yêu cầu đến API: ${response.statusCode}');
    return null;
  }
}

Future<Position> getCurrentPosition() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  return await Geolocator.getCurrentPosition();
}
