import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:http/http.dart' as http;
import 'package:tdlogistic_v2/customer/UI/widgets/search_bar.dart';
import 'package:tdlogistic_v2/customer/bloc/order_bloc.dart';
import 'package:tdlogistic_v2/customer/bloc/order_event.dart';

class NewLocation extends StatefulWidget {
  final String location;
  final String locationId;
  final String address;
  final bool isFav;
  final bool isEdit;
  final String description;
  final String name;
  final String phone;

  const NewLocation({
    super.key,
    required this.location,
    this.locationId = "",
    this.address = "",
    this.isFav = false,
    this.isEdit = false,
    this.description = "",
    this.name = "",
    this.phone = "",
  });

  @override
  State<NewLocation> createState() => _NewLocationState();
}

class _NewLocationState extends State<NewLocation> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _searchController.text = widget.address;
    super.initState();
  }

  void showDeleteConfirmationDialog(
      BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa địa điểm này không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng popup
              },
              child: const Text(
                'Hủy',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Màu nền đỏ cho nút xóa
              ),
              child: const Text('Xóa', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn địa điểm'),
        actions: [
          if (widget.isEdit)
            IconButton(
              onPressed: () {
                print("Click delete");
                showDeleteConfirmationDialog(context, () async {
                  Navigator.of(context).pop();
                  context.read<GetLocationBloc>().add(
                      DeleteLocation(widget.locationId, isFav: widget.isFav));
                  Navigator.of(context).pop();
                });
              },
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            MySearchBar(
              controller: _searchController,
              icon: const Icon(Icons.search),
              labelText: "Tìm kiếm địa điểm",
              onChanged: () async {
                setState(() {});
//
              },
              onTap: () {},
              onDelete: () {
                // Xử lý khi xóa văn bản
                setState(() {});
              },
            ),
            // Các widget khác trong NewLocation

            ElevatedButton(
              onPressed: _searchController.text == ""
                  ? null
                  : () async {
                      if (widget.isFav) {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewFavMark(
                              address: _searchController.text,
                              descriptin: widget.description,
                              name: widget.name,
                              phone: widget.phone,
                            ),
                          ),
                        );
                        if (result != null) {
                          Navigator.pop(context, result);
                        }
                      } else {
                        if (widget.location != "Nhà" &&
                            widget.location != "Công ty") {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewMark(
                                address: _searchController.text,
                                location: widget.location == "Thêm"
                                    ? ""
                                    : widget.location,
                              ),
                            ),
                          );
                          if (result != null) {
                            Navigator.pop(
                                context, [result, _searchController.text]);
                          }
                        } else {
                          Navigator.pop(context,
                              [widget.location, _searchController.text]);
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Tiếp tục',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewMark extends StatefulWidget {
  final String address;
  final String location;
  const NewMark({super.key, required this.address, this.location = ""});

  @override
  State<NewMark> createState() => _NewMarkState();
}

class _NewMarkState extends State<NewMark> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    _addressController.text = widget.address;
    _locationController.text = widget.location;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận địa điểm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(
              controller: _locationController,
              labelText: "Tên địa điểm",
              onChanged: (str) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressController,
              labelText: "Địa chỉ",
              onChanged: (str) {
                setState(() {});
              },
            ),
            ElevatedButton(
              onPressed: _locationController.text == "" ||
                      _addressController.text == ""
                  ? null
                  : () {
                      // Khi nhấn nút, chỉ pop NewMark với giá trị
                      Navigator.pop(context, _locationController.text);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Lưu',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required ValueChanged<String?> onChanged,
    required String labelText,
    bool isDes = false,
    bool fromContacts = false,
    bool isSender = true,
    bool addToFavo = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        maxLines: isDes ? 3 : 1,
        decoration: InputDecoration(
          labelText: labelText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: secondColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
        onChanged: onChanged,
        onTap: () {},
      ),
    );
  }
}

class NewFavMark extends StatefulWidget {
  final String address;
  final String descriptin;
  final String name;
  final String phone;
  const NewFavMark(
      {super.key,
      required this.address,
      this.descriptin = "",
      this.name = "",
      this.phone = ""});

  @override
  State<NewFavMark> createState() => _NewFavMarkState();
}

class _NewFavMarkState extends State<NewFavMark> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool phoneValid = true;

  bool checkPhoneValid() {
    setState(() {
      phoneValid = (_numberController.text[0] == '0' &&
          (_numberController.text.length == 10 ||
              _numberController.text.length == 11));
    });
    return phoneValid;
  }

  @override
  void initState() {
    // TODO: implement initState
    _addressController.text = widget.address;
    _nameController.text = widget.name;
    _numberController.text = widget.phone;
    _descriptionController.text = widget.descriptin;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác nhận địa điểm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(
              controller: _addressController,
              labelText: "Địa chỉ",
              onChanged: (str) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              labelText: "Mô tả",
              onChanged: (str) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _nameController,
              labelText: "Tên người nhận",
              onChanged: (str) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _numberController,
              labelText: "SĐT người nhận",
              onChanged: (str) {
                setState(() {});
              },
            ),
            if (!phoneValid)
              const Text("Vui lòng nhập đúng SĐT!",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _nameController.text == "" ||
                      _addressController.text == "" ||
                      _descriptionController.text == "" ||
                      _numberController.text == ""
                  ? null
                  : () {
                      if (checkPhoneValid()) {
                        // Khi nhấn nút, chỉ pop NewMark với giá trị
                        Navigator.pop(context, [
                          _nameController.text,
                          _numberController.text,
                          _descriptionController.text,
                          _addressController.text,
                        ]);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Lưu',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required ValueChanged<String?> onChanged,
    required String labelText,
    bool isDes = false,
    bool fromContacts = false,
    bool isSender = true,
    bool addToFavo = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        maxLines: isDes ? 3 : 1,
        decoration: InputDecoration(
          labelText: labelText,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: secondColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
        onChanged: onChanged,
        onTap: () {},
      ),
    );
  }
}
