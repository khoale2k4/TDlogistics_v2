import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:http/http.dart' as http;

class NewLocation extends StatefulWidget {
  final String location;
  final String address;
  final bool isFav;
  final bool isEdit;
  final String descriptin;
  final String name;
  final String phone;
  const NewLocation(
      {super.key,
      required this.location,
      this.address = "",
      this.isFav = false,
      this.isEdit = false,
      this.descriptin = "",
      this.name = "",
      this.phone = ""});

  @override
  State<NewLocation> createState() => _NewLocationState();
}

class _NewLocationState extends State<NewLocation> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchSuggestions = [];
  final String _apiKey = ggApiKey; // Thay bằng API Key của bạn

  Future<void> _getSearchSuggestions(String query) async {
    try {
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_apiKey&language=vi');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchSuggestions = data['predictions'];
        });
      } else {
        print("Error fetching suggestions: ${response.body}");
      }
    } catch (error) {
      print("Error fetching location: $error");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _searchController.text = widget.address;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn địa điểm'),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 80,
            left: 15,
            right: 15,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Nhập địa điểm",
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (query) {
                    if (query.isNotEmpty) {
                      _getSearchSuggestions(query);
                    } else {
                      setState(() {
                        _searchSuggestions = [];
                      });
                    }
                  },
                ),
                const SizedBox(height: 5),
                Container(
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20)),
                      color: Colors.white),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(0),
                    shrinkWrap: true,
                    itemCount: _searchSuggestions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_searchSuggestions[index]['description']),
                        onTap: () async {
                          if (widget.isFav) {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewFavMark(
                                    address: _searchSuggestions[index]
                                        ['description']),
                              ),
                            );
                            if (result != null) {
                              Navigator.pop(context, result);
                            }
                          } else {
                            if (widget.location == "Thêm") {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewMark(
                                      address: _searchSuggestions[index]
                                          ['description']),
                                ),
                              );
                              if (result != null) {
                                Navigator.pop(context, [
                                  result,
                                  _searchSuggestions[index]['description']
                                ]);
                              }
                            } else {
                              // Nếu không cần mở NewMark, pop với kết quả địa chỉ
                              Navigator.pop(context, [
                                widget.location,
                                _searchSuggestions[index]['description']
                              ]);
                            }
                          }
                        },
                      );
                    },
                  ),
                ),
                if (widget.isEdit) ...[
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: _searchController.text == ""
                        ? null
                        : () async {
                            if (widget.isFav) {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewFavMark(
                                    address: widget.address,
                                    descriptin: widget.descriptin,
                                    name: widget.name,
                                    phone: widget.phone,
                                  ),
                                ),
                              );
                              if (result != null) {
                                Navigator.pop(context, result);
                              }
                            } else {
                              if (widget.location == "Thêm") {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NewMark(address: widget.address),
                                  ),
                                );
                                if (result != null) {
                                  Navigator.pop(
                                      context, [result, widget.address]);
                                }
                              } else {
                                // Nếu không cần mở NewMark, pop với kết quả địa chỉ
                                Navigator.pop(
                                    context, [widget.location, widget.address]);
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NewMark extends StatefulWidget {
  final String address;
  const NewMark({super.key, required this.address});

  @override
  State<NewMark> createState() => _NewMarkState();
}

class _NewMarkState extends State<NewMark> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    _addressController.text = widget.address;
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
