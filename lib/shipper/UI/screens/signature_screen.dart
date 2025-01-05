import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key});

  @override
  _SignatureScreenState createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  Future<void> _saveSignature() async {
    if (await Permission.storage.request().isGranted) {
      final Uint8List? data = await _controller.toPngBytes();
      if (data != null) {
        final XFile? file = await _saveImageAsFile(data);
        Navigator.of(context).pop(file); // Trả về XFile
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission Denied')),
      );
    }
  }

  Future<XFile?> _saveImageAsFile(Uint8List data) async {
    try {
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(data);
      return XFile(file.path); // Trả về XFile
    } catch (e) {
      print("Error saving signature: $e");
      return null;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ký tên'),
      ),
      body: Column(
        children: [
          Signature(
            controller: _controller,
            height: MediaQuery.of(context).size.height - 300,
            backgroundColor: Colors.grey[200]!,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _controller.clear();
                },
                child: const Text('Xóa'),
              ),
              ElevatedButton(
                onPressed: _saveSignature,
                child: const Text('Lưu'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
