import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:http/http.dart' as http;
import 'package:tdlogistic_v2/customer/bloc/order_bloc.dart';
import 'package:tdlogistic_v2/customer/bloc/order_event.dart';
import 'package:tdlogistic_v2/customer/bloc/order_state.dart';
import 'package:tdlogistic_v2/customer/data/models/shipping_bill.dart';

class InsuranceForm extends StatefulWidget {
  final String initialNote;
  final List<Uint8List> initialImages;
  final bool initialInvoiceEnabled;
  final String initialCompanyName;
  final String initialAddress;
  final String initialTaxCode;
  final String initialEmail;

  const InsuranceForm({
    super.key,
    this.initialNote = '',
    this.initialImages = const [],
    this.initialInvoiceEnabled = false,
    this.initialCompanyName = '',
    this.initialAddress = '',
    this.initialTaxCode = '',
    this.initialEmail = '',
  });

  @override
  _InsuranceFormState createState() => _InsuranceFormState();
}

class _InsuranceFormState extends State<InsuranceForm> {
  late final TextEditingController _noteController;
  late final List<Uint8List> _images;
  late bool _isInvoiceEnabled;
  late final TextEditingController _companyNameController;
  late final TextEditingController _addressController;
  late final TextEditingController _taxCodeController;
  late final TextEditingController _emailController;
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialNote);
    _images = List.from(widget.initialImages);
    _isInvoiceEnabled = widget.initialInvoiceEnabled;
    _companyNameController =
        TextEditingController(text: widget.initialCompanyName);
    _addressController = TextEditingController(text: widget.initialAddress);
    _taxCodeController = TextEditingController(text: widget.initialTaxCode);
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is disposed
    _noteController.dispose();
    _companyNameController.dispose();
    _addressController.dispose();
    _taxCodeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _toggleInvoice(bool? value) {
    setState(() {
      _isInvoiceEnabled = value ?? false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_images.length >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chỉ được chọn tối đa 2 ảnh')),
      );
      return;
    }
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _images.add(bytes);
      });
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa bảo hiểm này?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng hộp thoại
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                // Logic xóa bảo hiểm
                Navigator.pop(context); // Đóng hộp thoại sau khi xóa
                Navigator.pop(context);
              },
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
        backgroundColor: Colors.white,
        title: const Text(
          'Bảo hiểm',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context, "QUAY VỀ"); // Quay về màn hình trước
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              _showDeleteConfirmationDialog(); // Hiển thị hộp thoại xác nhận xóa
            },
          ),
        ],
        elevation: 1, // Độ bóng nhẹ cho AppBar
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNoteSection(),
            const Divider(thickness: 1, height: 30),
            _buildImagePickerSection(),
            const Divider(thickness: 1, height: 30),
            _buildInvoiceSwitch(),
            if (_isInvoiceEnabled) _buildInvoiceForm(),
            const Divider(thickness: 1, height: 30),
            _buildInsuranceDetailsButton(),
            const SizedBox(height: 16),
            _buildDoneButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ghi chú",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          decoration: const InputDecoration(
            hintText: 'Nhập ghi chú',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white, // Light background for input

            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: secondColor, width: 1.5),
            ),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildImagePickerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Chọn ảnh",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        if (_images.length < 2)
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await showDialog<ImageSource>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Chọn nguồn ảnh"),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, ImageSource.camera),
                          child: const Text("Chụp ảnh"),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, ImageSource.gallery),
                          child: const Text("Chọn từ máy"),
                        ),
                      ],
                    ),
                  );
                  if (result != null) {
                    await _pickImage(result);
                  }
                },
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Chọn ảnh'),
              ),
              const SizedBox(width: 16),
              Text('${_images.length}/2 ảnh đã chọn'),
            ],
          ),
        const SizedBox(height: 8),
        _buildImageGrid(),
      ],
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _images.length,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                _images[index],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: CircleAvatar(
                maxRadius: 20,
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _images.removeAt(index);
                    });
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInvoiceSwitch() {
    return SwitchListTile(
      title: const Text('Hoá đơn'),
      subtitle: const Text('Bật để điền thông tin hoá đơn'),
      value: _isInvoiceEnabled,
      onChanged: _toggleInvoice,
      activeColor: mainColor, // Use mainColor for the switch
    );
  }

  Widget _buildInvoiceForm() {
    return BlocListener<CreateOrderBloc, OrderState>(
      listener: (context, state) {
        if (state is GotShippingBill) {
          setState(() {
            _companyNameController.text = state.sb.companyName ?? '';
            _addressController.text = state.sb.companyAddress ?? '';
            _taxCodeController.text = state.sb.taxCode ?? '';
            _emailController.text = state.sb.email ?? '';
            isLoading = false;
          });
        } else if (state is CreatedShippingBill) {
          setState(() {
            isLoading = false;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Tạo hóa đơn thành công!',
                ),
                backgroundColor: secondColor,
              ),
            );
          });
        } else if (state is FailedCreatingBill) {
          setState(() {
            isLoading = false;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không thể tạo hóa đơn.'),
                backgroundColor: mainColor,
              ),
            );
          });
        } else if (state is FailedGettingBill) {
          setState(() {
            isLoading = false;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không thể lấy thông tin hóa đơn.'),
                backgroundColor: mainColor,
              ),
            );
          });
        }
      },
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildFormContent(
              onFetchInvoice: () {
                context.read<CreateOrderBloc>().add(GetShippingBill());
                setState(() {
                  isLoading = true;
                });
              },
              onSaveInvoice: () {
                context.read<CreateOrderBloc>().add(
                      CreateShippingBill(ShippingBill(
                        companyName: _companyNameController.text,
                        companyAddress: _addressController.text,
                        taxCode: _taxCodeController.text,
                        email: _emailController.text,
                      )),
                    );
                setState(() {
                  isLoading = true;
                });
              },
            ),
    );
  }

  Widget _buildFormContent({
    required VoidCallback onFetchInvoice,
    required VoidCallback onSaveInvoice,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        TextField(
          controller: _companyNameController,
          decoration: const InputDecoration(
            labelText: 'Tên công ty',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white, // Light background for input
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: secondColor, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Địa chỉ',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white, // Light background for input
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: secondColor, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _taxCodeController,
          decoration: const InputDecoration(
            labelText: 'Mã số thuế',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white, // Light background for input
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: secondColor, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email công ty',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white, // Light background for input
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: secondColor, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: onFetchInvoice,
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor, // Main color for button
              ),
              child: const Text('Hoá đơn gần nhất',
                  style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: onSaveInvoice,
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor, // Main color for button
              ),
              child: const Text('Lưu hoá đơn',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsuranceDetailsButton() {
    return GestureDetector(
      onTap: () {
        // Hiển thị thông tin chi tiết bảo hiểm
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: mainColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: const Text(
          'Nhấn vào đây để xem chi tiết bảo hiểm',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDoneButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context, {
          'note': _noteController.text,
          'images': _images,
          'isInvoiceEnabled': _isInvoiceEnabled,
          'companyName': _companyNameController.text,
          'address': _addressController.text,
          'taxCode': _taxCodeController.text,
          'email': _emailController.text,
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: secondColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6,
            ),
          ],
        ),
        child: const Text(
          'Xong',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
