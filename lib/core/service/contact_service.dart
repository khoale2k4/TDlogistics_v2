import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';

final FlutterNativeContactPicker _contactPicker = FlutterNativeContactPicker();
Future<List<String?>> pickFullnameAndPhone() async {
  try {
    Contact? contact = await _contactPicker.selectContact();
    return [contact!.fullName, contact.phoneNumbers![0]];
  } catch (e) {
    print('Failed to pick contact: $e');
    return [];
  }
}
