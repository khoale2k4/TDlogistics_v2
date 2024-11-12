import 'dart:typed_data';
import 'package:flutter/material.dart';

class InsuranceDetailsPage extends StatelessWidget {
  final TextEditingController noteController;
  final List<Uint8List> images;
  final bool isInvoiceEnabled;
  final TextEditingController companyNameController;
  final TextEditingController addressController;
  final TextEditingController taxCodeController;
  final TextEditingController emailController;

  InsuranceDetailsPage({
    required this.noteController,
    required this.images,
    required this.isInvoiceEnabled,
    required this.companyNameController,
    required this.addressController,
    required this.taxCodeController,
    required this.emailController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết bảo hiểm"),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Note Section
            const Text(
              "Ghi chú",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              noteController.text.isNotEmpty
                  ? noteController.text
                  : "Không có ghi chú",
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(height: 30),

            // Images Section
            const Text(
              "Hình ảnh",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            images.isNotEmpty
                ? Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: images
                        .map((image) => Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ))
                        .toList(),
                  )
                : const Text(
                    "Chưa có ảnh nào được thêm",
                    style: TextStyle(color: Colors.grey),
                  ),
            const Divider(height: 30),

            // Invoice Information Section
            const Text(
              "Thông tin hóa đơn",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            isInvoiceEnabled
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                          "Tên công ty", companyNameController.text),
                      _buildDetailRow("Địa chỉ", addressController.text),
                      _buildDetailRow("Mã số thuế", taxCodeController.text),
                      _buildDetailRow("Email công ty", emailController.text),
                    ],
                  )
                : const Text(
                    "Không yêu cầu hóa đơn",
                    style: TextStyle(color: Colors.grey),
                  ),
            const Divider(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : "Chưa có thông tin",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
