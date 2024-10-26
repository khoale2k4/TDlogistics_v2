import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlogistic_v2/core/models/order_model.dart';
import 'package:tdlogistic_v2/customer/bloc/order_bloc.dart';
import 'package:tdlogistic_v2/customer/bloc/order_event.dart';
import 'package:tdlogistic_v2/customer/bloc/order_state.dart';
import 'package:tdlogistic_v2/core/constant.dart';

class CreateOrder extends StatefulWidget {
  const CreateOrder({super.key});

  @override
  State<CreateOrder> createState() => _CreateOrderState();
}

class _CreateOrderState extends State<CreateOrder> {
  bool isCalculating = false;
  num fee = 0;

  // Trang nhập thông tin chữ
  final _senderNameController = TextEditingController();
  final _senderAddressController = TextEditingController();
  final _senderDistrictController = TextEditingController();
  final _senderCityController = TextEditingController(text: "TPHCM");
  final _senderPhoneController = TextEditingController();
  final _receiverNameController = TextEditingController();
  final _receiverAddressController = TextEditingController();
  final _receiverDistrictController = TextEditingController();
  final _receiverCityController = TextEditingController(text: "TPHCM");
  final _receiverPhoneController = TextEditingController();

  // Validation flags
  bool _isSenderNameValid = true;
  bool _isSenderAddressValid = true;
  bool _isSenderDistrictValid = true;
  bool _isSenderCityValid = true;
  bool _isSenderPhoneValid = true;
  bool _isReceiverNameValid = true;
  bool _isReceiverAddressValid = true;
  bool _isReceiverDistrictValid = true;
  bool _isReceiverCityValid = true;
  bool _isReceiverPhoneValid = true;

  bool validePhone(String phone) {
    if (phone.length > 11 || phone.length < 10) return false;
    if (phone[0] != '0') return false;
    return true;
  }

  bool _validateInputs() {
    setState(() {
      _isSenderNameValid = _senderNameController.text.isNotEmpty;
      _isSenderAddressValid = _senderAddressController.text.isNotEmpty;
      _isSenderDistrictValid = _senderDistrictController.text.isNotEmpty;
      _isSenderCityValid = _senderCityController.text.isNotEmpty;
      _isSenderPhoneValid = validePhone(_senderPhoneController.text);
      _isReceiverNameValid = _receiverNameController.text.isNotEmpty;
      _isReceiverAddressValid = _receiverAddressController.text.isNotEmpty;
      _isReceiverDistrictValid = _receiverDistrictController.text.isNotEmpty;
      _isReceiverCityValid = _receiverCityController.text.isNotEmpty;
      _isReceiverPhoneValid = validePhone(_receiverPhoneController.text);
    });

    return _isSenderNameValid &&
        _isSenderAddressValid &&
        _isSenderDistrictValid &&
        _isSenderCityValid &&
        _isSenderPhoneValid &&
        _isReceiverNameValid &&
        _isReceiverAddressValid &&
        _isReceiverDistrictValid &&
        _isReceiverCityValid &&
        _isReceiverPhoneValid;
  }

  ////////////////////////////////

  // Trang nhập thông tin số
  final _cashOnDeliveryController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String _selectedDeliveryMethod = 'Chuyển phát nhanh';

  bool _isLengthEmpty = true;
  bool _isWidthEmpty = true;
  bool _isHeightEmpty = true;
  bool _isWeightEmpty = true;

  final List<String> _deliveryMethods = [
    'Chuyển phát nhanh',
    'Chuyển phát thường',
    'Giao hàng tiết kiệm',
  ];

  bool _validateNumberInputs() {
    setState(() {
      _isLengthEmpty = _lengthController.text.isNotEmpty &&
          int.tryParse(_lengthController.text) != null;
      _isWidthEmpty = _widthController.text.isNotEmpty &&
          int.tryParse(_widthController.text) != null;
      _isHeightEmpty = _heightController.text.isNotEmpty &&
          int.tryParse(_heightController.text) != null;
      _isWeightEmpty = _weightController.text.isNotEmpty &&
          int.tryParse(_weightController.text) != null;
    });

    // If any of the fields are not valid, return false
    return _isLengthEmpty && _isWidthEmpty && _isHeightEmpty && _isWeightEmpty;
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<OrderBlocCus>().add(StartOrder());
    // });
  }

  late PageController _pageController;
  final _numberController = TextEditingController();
  int _currentPage = 0;

  @override
  void dispose() {
    // Dispose các trang nhập
    _senderNameController.dispose();
    _senderAddressController.dispose();
    _senderDistrictController.dispose();
    _senderCityController.dispose();
    _senderPhoneController.dispose();
    _receiverNameController.dispose();
    _receiverAddressController.dispose();
    _receiverDistrictController.dispose();
    _receiverCityController.dispose();
    _receiverPhoneController.dispose();

    _cashOnDeliveryController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _weightController.dispose();

    _pageController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  void handleNewOrder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đơn hàng đã được tạo thành công!')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildMain(context),
                  _buildTextInputPage(),
                  _buildNumberInputPage(),
                  _buildConfirmPage(context),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMain(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 200,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(150),
                bottomRight: Radius.circular(150),
              ),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.only(top: 70.0, left: 20, right: 20),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Image.asset('lib/assets/logo.png', height: 75),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
          Container(
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              icon: const Icon(Icons.add, color: Colors.green, size: 40),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusLabel(String? statusCode) {
    // Custom method to create colored status labels
    Color labelColor;
    String statusText;

    switch (statusCode) {
      case "1":
        labelColor = Colors.orange;
        statusText = "Chờ xác nhận";
        break;
      case "2":
        labelColor = Colors.blue;
        statusText = "Đang giao";
        break;
      case "3":
        labelColor = Colors.green;
        statusText = "Hoàn thành";
        break;
      case "4":
        labelColor = mainColor;
        statusText = "Đã hủy";
        break;
      default:
        labelColor = Colors.grey;
        statusText = "Không xác định";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: labelColor.withOpacity(0.1),
        border: Border.all(color: labelColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(color: labelColor),
      ),
    );
  }

  void _showOrderDetailsDialog(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(order.trackingNumber ?? ''),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Người gửi: ${order.nameSender ?? ''}'),
                Text('SĐT: ${order.phoneNumberSender ?? ''}'),
                const SizedBox(height: 8),
                Text('Người nhận: ${order.nameReceiver ?? ''}'),
                Text('SĐT: ${order.phoneNumberReceiver ?? ''}'),
                const SizedBox(height: 8),
                Text(
                    'Địa chỉ gửi: ${order.provinceSource ?? ''}, ${order.districtSource ?? ''}, ${order.wardSource ?? ''}, ${order.detailSource ?? ''}'),
                const SizedBox(height: 8),
                Text(
                    'Địa chỉ nhận: ${order.provinceDest ?? ''}, ${order.districtDest ?? ''}, ${order.wardDest ?? ''}, ${order.detailDest ?? ''}'),
                const SizedBox(height: 8),
                Text('Khối lượng: ${order.mass?.toStringAsFixed(2) ?? ''} kg'),
                Text('Phí: ${order.fee?.toStringAsFixed(2) ?? ''} VNĐ'),
                const SizedBox(height: 8),
                Text('Trạng thái đơn hàng: ${order.statusCode ?? ''}'),
                const SizedBox(height: 8),

                // Thay thế ListView.builder bằng Column + List.generate
                order.journies != null
                    ? Column(
                        children:
                            List.generate(order.journies!.length, (index) {
                          final journey = order.journies![index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                const Icon(Icons.done),
                                Text(journey.message ?? ""),
                              ],
                            ),
                          );
                        }),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextInputPage() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 70.0, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin người gửi:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _senderNameController,
              labelText: 'Tên người gửi',
              isValid: _isSenderNameValid,
            ),
            _buildTextField(
              controller: _senderAddressController,
              labelText: 'Số nhà, tên đường',
              isValid: _isSenderAddressValid,
            ),
            _buildTextField(
              controller: _senderDistrictController,
              labelText: 'Quận huyện',
              isValid: _isSenderDistrictValid,
            ),
            _buildTextField(
              controller: _senderCityController,
              labelText: 'Tỉnh thành',
              isValid: _isSenderCityValid,
            ),
            _buildTextField(
              controller: _senderPhoneController,
              labelText: 'Số điện thoại',
              isValid: _isSenderPhoneValid,
            ),
            const SizedBox(height: 20),
            const Text(
              'Thông tin người nhận:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _receiverNameController,
              labelText: 'Tên người nhận',
              isValid: _isReceiverNameValid,
            ),
            _buildTextField(
              controller: _receiverAddressController,
              labelText: 'Số nhà, tên đường',
              isValid: _isReceiverAddressValid,
            ),
            _buildTextField(
              controller: _receiverDistrictController,
              labelText: 'Quận huyện',
              isValid: _isReceiverDistrictValid,
            ),
            _buildTextField(
              controller: _receiverCityController,
              labelText: 'Tỉnh thành',
              isValid: _isReceiverCityValid,
            ),
            _buildTextField(
              controller: _receiverPhoneController,
              labelText: 'Số điện thoại',
              isValid: _isReceiverPhoneValid,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required bool isValid,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: labelText,
          errorText: isValid ? null : 'Vui lòng nhập $labelText',
        ),
      ),
    );
  }

  Widget _buildNumberInputPage() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 70.0, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập thông tin dạng số:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 20),

            // Trường nhập số tiền thu hộ (không cần kiểm tra hợp lệ)
            _buildNumberField(
              controller: _cashOnDeliveryController,
              labelText: 'Số tiền thu hộ (VNĐ)',
              hintText: 'Nhập số tiền',
              isEmpty: true,
            ),
            const SizedBox(height: 20),

            // Trường nhập chiều dài
            _buildNumberField(
              controller: _lengthController,
              labelText: 'Chiều dài (cm)',
              hintText: 'Nhập chiều dài',
              isEmpty: _isLengthEmpty,
            ),
            const SizedBox(height: 20),

            // Trường nhập chiều rộng
            _buildNumberField(
              controller: _widthController,
              labelText: 'Chiều rộng (cm)',
              hintText: 'Nhập chiều rộng',
              isEmpty: _isWidthEmpty,
            ),
            const SizedBox(height: 20),

            // Trường nhập chiều cao
            _buildNumberField(
              controller: _heightController,
              labelText: 'Chiều cao (cm)',
              hintText: 'Nhập chiều cao',
              isEmpty: _isHeightEmpty,
            ),
            const SizedBox(height: 20),

            // Trường nhập khối lượng
            _buildNumberField(
              controller: _weightController,
              labelText: 'Khối lượng (g)',
              hintText: 'Nhập khối lượng',
              isEmpty: _isWeightEmpty,
            ),
            const SizedBox(height: 20),

            // Dropdown cho phương thức giao
            _buildDropdownField(),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    bool isEmpty = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: labelText,
        errorText: isEmpty ? null : 'Vui lòng nhập $labelText',
      ),
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phương thức giao:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _selectedDeliveryMethod,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Chọn phương thức giao',
          ),
          items: _deliveryMethods.map((String method) {
            return DropdownMenuItem<String>(
              value: method,
              child: Text(method),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedDeliveryMethod = newValue!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildConfirmPage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.only(top: 70.0, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Xác nhận thông tin',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const Text(
                'Thông tin người gửi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tên người gửi: ${_senderNameController.text}'),
                  Text('Địa chỉ người gửi: ${_senderAddressController.text}'),
                  Text('Quận/Huyện: ${_senderDistrictController.text}'),
                  Text('Thành phố: ${_senderCityController.text}'),
                  Text('Số điện thoại: ${_senderPhoneController.text}'),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Thông tin người nhận',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tên người nhận: ${_receiverNameController.text}'),
                  Text(
                      'Địa chỉ người nhận: ${_receiverAddressController.text}'),
                  Text('Quận/Huyện: ${_receiverDistrictController.text}'),
                  Text('Thành phố: ${_receiverCityController.text}'),
                  Text('Số điện thoại: ${_receiverPhoneController.text}'),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Thông tin gói hàng',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thu hộ (COD): ${_cashOnDeliveryController.text} VNĐ'),
                  Text('Chiều dài: ${_lengthController.text} cm'),
                  Text('Chiều rộng: ${_widthController.text} cm'),
                  Text('Chiều cao: ${_heightController.text} cm'),
                  Text('Cân nặng: ${_weightController.text} kg'),
                  Text('Phương thức giao hàng: $_selectedDeliveryMethod'),
                  Row(
                    children: [
                      const Text('Chi phí giao hàng: '),
                      BlocBuilder<OrderBlocFee, OrderState>(
                        builder: (context, state) {
                          if (state is OrderFeeCalculating) {
                            return const CircularProgressIndicator(); // Hiển thị loading khi đang tính phí
                          } else if (state is OrderFeeCalculated) {
                            return Text(
                                '${state.fee} VND'); // Hiển thị phí sau khi tính toán
                          } else if (state is OrderFeeCalculationFailed) {
                            return Text(
                                'Lỗi: ${state.error}'); // Hiển thị lỗi nếu có vấn đề xảy ra
                          } else {
                            return const Text('Chưa tính phí');
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => handleNewOrder(context),
                  child: const Text('Xác nhận và tạo đơn hàng'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
          const SizedBox(width: 20,),
        if (_currentPage > 0)
          ElevatedButton(
            onPressed: () {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: const Text('Quay lại'),
          ),
        if (_currentPage >= 1 && _currentPage <= 2) _buildClearButton(),
        if (_currentPage > 0 && _currentPage < 3)
          ElevatedButton(
            onPressed: () async {
              if (_currentPage == 1) {
                // Validate text inputs on page 1
                if (_validateInputs()) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              } else if (_currentPage == 2) {
                // Validate number inputs on page 2
                if (_validateNumberInputs()) {
                  context.read<OrderBlocFee>().add(
                        CalculateFee(
                          _senderCityController.text,
                          _senderDistrictController.text,
                          _senderAddressController.text,
                          _receiverCityController.text,
                          _receiverDistrictController.text,
                          _receiverAddressController.text,
                          _selectedDeliveryMethod,
                          int.parse(_heightController.text),
                          int.parse(_lengthController.text),
                          int.parse(_weightController.text),
                          int.parse(_widthController.text),
                        ),
                      );
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: isCalculating
                ? const CircularProgressIndicator()
                : const Text(
                    'Tiếp tục',
                  ),
          ),
          const SizedBox(width: 20,)
      ],
    );
  }

  Widget _buildClearButton() {
    return ElevatedButton(
      onPressed: () {
        if (_currentPage == 1) {
          setState(() {
            _senderNameController.text = "";
            _senderAddressController.text = "";
            _senderDistrictController.text = "";
            _senderCityController.text = "";
            _senderPhoneController.text = "";
            _receiverNameController.text = "";
            _receiverAddressController.text = "";
            _receiverDistrictController.text = "";
            _receiverCityController.text = "";
            _receiverPhoneController.text = "";
          });
        } else if (_currentPage == 2) {
          setState(() {
            _cashOnDeliveryController.text = "";
            _lengthController.text = "";
            _widthController.text = "";
            _heightController.text = "";
            _weightController.text = "";
          });
        }

        // Hiển thị thông báo sau khi xóa
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dữ liệu đã được xóa'),
            backgroundColor: Colors.green,
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade100, // Nút có màu đỏ để chỉ ra nút xóa
      ),
      child: const Icon(Icons.cleaning_services_outlined),
    );
  }
}
