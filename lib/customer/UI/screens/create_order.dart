import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/customer/UI/screens/map2markers.dart';
import 'package:tdlogistic_v2/customer/bloc/order_bloc.dart';
import 'package:tdlogistic_v2/customer/bloc/order_event.dart';
import 'package:tdlogistic_v2/customer/bloc/order_state.dart';
import 'package:dvhcvn/dvhcvn.dart' as dvhcvn;
import 'package:tdlogistic_v2/customer/data/models/create_order.dart';

class CreateOrder extends StatefulWidget {
  const CreateOrder({super.key});

  @override
  State<CreateOrder> createState() => _CreateOrderState();
}

class _CreateOrderState extends State<CreateOrder> {
  bool isCalculating = false;
  num fee = 0;
  double _buttonX = 350.0;
  double _buttonY = 50.0;

  // Trang nhập thông tin chữ
  final _senderNameController = TextEditingController();
  final _senderAddressController = TextEditingController();
  final _senderDistrictController = TextEditingController();
  final _senderWardController = TextEditingController();
  final _senderCityController = TextEditingController();
  final _senderPhoneController = TextEditingController();
  final _receiverNameController = TextEditingController();
  final _receiverAddressController = TextEditingController();
  final _receiverWardController = TextEditingController();
  final _receiverDistrictController = TextEditingController();
  final _receiverCityController = TextEditingController();
  final _receiverPhoneController = TextEditingController();

  // Validation flags
  bool _isSenderNameValid = true;
  bool _isSenderAddressValid = true;
  bool _isSenderDistrictValid = true;
  bool _isSenderWardValid = true;
  bool _isSenderCityValid = true;
  bool _isSenderPhoneValid = true;
  bool _isReceiverNameValid = true;
  bool _isReceiverAddressValid = true;
  bool _isReceiverDistrictValid = true;
  bool _isReceiverWardValid = true;
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
  final _cashOnDeliveryController = TextEditingController(text: "0");
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
    _pageController = PageController(initialPage: 1);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<OrderBlocCus>().add(StartOrder());
    // });
  }

  late PageController _pageController;
  final _numberController = TextEditingController();
  int _currentPage = 1;

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
    print("Đang tạo đơn hàng");
    context.read<CreateOrderBloc>().add(
          CreateOrderEvent(
            CreateOrderObject(
              cod: (int.parse(_cashOnDeliveryController.text)),
              detailDest: _receiverAddressController.text,
              detailSource: _senderAddressController.text,
              districtDest: _receiverDistrictController.text,
              districtSource: _senderDistrictController.text,
              height: (int.parse(_heightController.text)),
              length: (int.parse(_lengthController.text)),
              mass: (int.parse(_weightController.text)),
              width: (int.parse(_widthController.text)),
              nameReceiver: _receiverNameController.text,
              nameSender: _senderNameController.text,
              phoneNumberReceiver: _receiverPhoneController.text,
              phoneNumberSender: _senderPhoneController.text,
              provinceDest: _receiverCityController.text,
              provinceSource: _senderCityController.text,
              serviceType: _selectedDeliveryMethod,
              wardDest: _receiverWardController.text,
              wardSource: _senderWardController.text,
            ),
          ),
        );
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('Đơn hàng đã được tạo thành công!')),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              const SizedBox(height: 50),
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
              const SizedBox(height: 50),
            ],
          ),

          // Draggable button
          Positioned(
            left: _buttonX,
            top: _buttonY,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _buttonX += details.delta.dx;
                  _buttonY += details.delta.dy;
                });
              },
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Map2Markers(
                            startAddress: "${_senderAddressController.text} ${_senderWardController.text} ${_senderDistrictController.text} ${_senderCityController.text}",
                            endAddress: "${_receiverAddressController.text} ${_receiverWardController.text} ${_receiverDistrictController.text} ${_receiverCityController.text}",
                            ),
                        ),
                      );
                  
                },
                child: const Icon(Icons.map, color: mainColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMain(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
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

  Widget _buildTextInputPage() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 70.0, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin người gửi:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 10),
            _buildTextField(
                controller: _senderNameController,
                labelText: 'Tên người gửi',
                isValid: _isSenderNameValid,
                onChanged: (value) {
                  _isSenderNameValid = true;
                }),
            _buildDropdown(
              items: (dvhcvn.level1s.map((level) => level.name).toList()
                ..insert(0, "Vui lòng chọn tỉnh thành")),
              selectedValue: _senderCityController.text.isNotEmpty
                  ? _senderCityController.text
                  : null,
              labelText: 'Tỉnh thành',
              isValid: _isSenderCityValid,
              onChanged: (value) {
                setState(() {
                  _senderCityController.text = value ?? "";
                  _senderDistrictController.clear();
                  _senderWardController.clear();
                  _isSenderCityValid =
                      value != null && value != "Vui lòng chọn tỉnh thành";
                });
              },
            ),
            if (_senderCityController.text.isNotEmpty)
              _buildDropdown(
                items: (dvhcvn
                        .findLevel1ByName(_senderCityController.text)
                        ?.children
                        .map((level) => level.name)
                        .toList() ??
                    []),
                selectedValue: _senderDistrictController.text.isNotEmpty
                    ? _senderDistrictController.text
                    : null,
                labelText: 'Quận/Huyện',
                isValid: _isSenderDistrictValid,
                onChanged: (value) {
                  setState(() {
                    _senderDistrictController.text = value ?? "";
                    _senderWardController.clear();
                    _isSenderDistrictValid = value != null;
                  });
                },
              ),
            if (_senderDistrictController.text.isNotEmpty)
              _buildDropdown(
                items: (dvhcvn
                        .findLevel1ByName(_senderCityController.text)
                        ?.findLevel2ByName(_senderDistrictController.text)!
                        .children
                        .map((level) => level.name)
                        .toList() ??
                    []),
                selectedValue: _senderWardController.text.isNotEmpty
                    ? _senderWardController.text
                    : null,
                labelText: 'Phường xã',
                isValid: _isSenderWardValid,
                onChanged: (value) {
                  setState(() {
                    _senderWardController.text = value ?? "";
                    _isSenderWardValid = value != null;
                  });
                },
              ),
            _buildTextField(
                controller: _senderAddressController,
                labelText: 'Số nhà, tên đường',
                isValid: _isSenderAddressValid,
                onChanged: (value) {
                  _isSenderAddressValid = true;
                }),
            _buildTextField(
                controller: _senderPhoneController,
                labelText: 'Số điện thoại',
                isValid: _isSenderPhoneValid,
                onChanged: (value) {
                  _isSenderPhoneValid = true;
                }),
            const SizedBox(height: 20),
            const Text(
              'Thông tin người nhận:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 10),
            _buildTextField(
                controller: _receiverNameController,
                labelText: 'Tên người nhận',
                isValid: _isReceiverNameValid,
                onChanged: (value) {
                  _isReceiverNameValid = true;
                }),
            _buildDropdown(
              items: (dvhcvn.level1s.map((level) => level.name).toList()
                ..insert(0, "Vui lòng chọn tỉnh thành")),
              selectedValue: _receiverCityController.text.isNotEmpty
                  ? _receiverCityController.text
                  : null,
              labelText: 'Tỉnh thành',
              isValid: _isReceiverCityValid,
              onChanged: (value) {
                setState(() {
                  _receiverCityController.text = value ?? "";
                  _receiverDistrictController.clear();
                  _receiverWardController.clear();
                  _isReceiverCityValid =
                      value != null && value != "Vui lòng chọn tỉnh thành";
                });
              },
            ),
            if (_receiverCityController.text.isNotEmpty)
              _buildDropdown(
                items: (dvhcvn
                        .findLevel1ByName(_receiverCityController.text)
                        ?.children
                        .map((level) => level.name)
                        .toList() ??
                    []),
                selectedValue: _receiverDistrictController.text.isNotEmpty
                    ? _receiverDistrictController.text
                    : null,
                labelText: 'Quận/Huyện',
                isValid: _isReceiverDistrictValid,
                onChanged: (value) {
                  setState(() {
                    _receiverDistrictController.text = value ?? "";
                    _receiverWardController.clear();
                    _isReceiverDistrictValid = value != null;
                  });
                },
              ),
            if (_receiverDistrictController.text.isNotEmpty)
              _buildDropdown(
                items: (dvhcvn
                        .findLevel1ByName(_receiverCityController.text)
                        ?.findLevel2ByName(_receiverDistrictController.text)!
                        .children
                        .map((level) => level.name)
                        .toList() ??
                    []),
                selectedValue: _receiverWardController.text.isNotEmpty
                    ? _receiverWardController.text
                    : null,
                labelText: 'Phường xã',
                isValid: _isReceiverWardValid,
                onChanged: (value) {
                  setState(() {
                    _receiverWardController.text = value ?? "";
                    _isReceiverWardValid = value != null;
                  });
                },
              ),
            _buildTextField(
                controller: _receiverAddressController,
                labelText: 'Số nhà, tên đường',
                isValid: _isReceiverAddressValid,
                onChanged: (value) {
                  _isReceiverAddressValid = true;
                }),
            _buildTextField(
                controller: _receiverPhoneController,
                labelText: 'Số điện thoại',
                isValid: _isReceiverPhoneValid,
                onChanged: (value) {
                  _isReceiverPhoneValid = true;
                }),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required bool isValid,
    required ValueChanged<String?> onChanged,
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
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdown({
    required String labelText,
    required List<String> items,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
    required bool isValid,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: labelText,
          errorText: isValid ? null : 'Vui lòng chọn $labelText',
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        hint: Text('Vui lòng chọn $labelText'),
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
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
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
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
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
              ),
              const Text(
                'Thông tin người gửi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tên người gửi: ${_senderNameController.text}', style: const TextStyle(fontSize: 18),),
                  Text('Địa chỉ người gửi: ${_senderAddressController.text}', style: const TextStyle(fontSize: 18),),
                  Text('Phường/Xã: ${_senderWardController.text}', style: const TextStyle(fontSize: 18),),
                  Text('Quận/Huyện: ${_senderDistrictController.text}', style: const TextStyle(fontSize: 18),),
                  Text('Thành phố: ${_senderCityController.text}', style: const TextStyle(fontSize: 18),),
                  Text('Số điện thoại: ${_senderPhoneController.text}', style: const TextStyle(fontSize: 18),),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Thông tin người nhận',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tên người nhận: ${_receiverNameController.text}', style: const TextStyle(fontSize: 18),),
                  Text(
                      'Địa chỉ người nhận: ${_receiverAddressController.text}', style: const TextStyle(fontSize: 18),),
                  Text('Phường/Xã: ${_receiverWardController.text}', style: const TextStyle(fontSize: 18),),
                  Text('Quận/Huyện: ${_receiverDistrictController.text}', style: const TextStyle(fontSize: 18),),
                  Text('Thành phố: ${_receiverCityController.text}', style: const TextStyle(fontSize: 18),),
                  Text('Số điện thoại: ${_receiverPhoneController.text}', style: const TextStyle(fontSize: 18),),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Thông tin gói hàng',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thu hộ (COD): ${_cashOnDeliveryController.text} VNĐ', style: const TextStyle(fontSize: 18),),
                  Text('Chiều dài: ${_lengthController.text} cm', style: const TextStyle(fontSize: 18),),
                  Text('Chiều rộng: ${_widthController.text} cm', style: const TextStyle(fontSize: 18),),
                  Text('Chiều cao: ${_heightController.text} cm', style: const TextStyle(fontSize: 18),),
                  Text('Cân nặng: ${_weightController.text} kg', style: const TextStyle(fontSize: 18),),
                  Text('Phương thức giao hàng: $_selectedDeliveryMethod', style: const TextStyle(fontSize: 18),),
                  Row(
                    children: [
                      const Text('Chi phí giao hàng: '),
                      BlocBuilder<OrderBlocFee, OrderState>(
                        builder: (context, state) {
                          if (state is OrderFeeCalculating) {
                            return const CircularProgressIndicator(); // Hiển thị loading khi đang tính phí
                          } else if (state is OrderFeeCalculated) {
                            return Text(
                                '${state.fee} VND', style: const TextStyle(fontSize: 18),); // Hiển thị phí sau khi tính toán
                          } else if (state is OrderFeeCalculationFailed) {
                            return Text(
                                'Lỗi: ${state.error}', style: const TextStyle(fontSize: 18),); // Hiển thị lỗi nếu có vấn đề xảy ra
                          } else {
                            return const Text('Chưa tính phí', style: const TextStyle(fontSize: 18),);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: BlocBuilder<CreateOrderBloc, OrderState>(
                    builder: (context, state) {
                  if (state is OrderCreating) {
                    return const CircularProgressIndicator();
                  } else if (state is OrderCreateFaild) {
                    return Text(state.error);
                  } else {
                    if (state is OrderCreated) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Đơn hàng đã được tạo thành công!')),
                      );
                    }
                    return ElevatedButton(
                      onPressed: () => handleNewOrder(context),
                      child: const Text('Xác nhận và tạo đơn hàng'),
                    );
                  }
                }),
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
        const SizedBox(
          width: 20,
        ),
        if (_currentPage > 0)
          ElevatedButton(
            onPressed: () {
              if (_currentPage == 1) {
                Navigator.pop(context);
              } else {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
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
                  _cashOnDeliveryController.text =
                      _cashOnDeliveryController.text == ""
                          ? _cashOnDeliveryController.text
                          : "0";
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
        const SizedBox(
          width: 20,
        )
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

  void createOrderPopup(BuildContext context, bool isSuccess, String message) {
    // Đảm bảo dialog được gọi sau khi build hoàn tất
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(isSuccess
                ? 'Tạo đơn hàng thành công'
                : 'Tạo đơn hàng thất bại!'),
            content: isSuccess
                ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          spreadRadius: 4,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      radius: 30,
                      child: const Icon(
                        Icons.done_outline_sharp,
                        color: Colors.green,
                        size: 30,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Text(message),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              spreadRadius: 4,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.red.shade100,
                          radius: 30,
                          child: const Icon(
                            Icons.do_not_disturb_outlined,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ), // Hiển thị thông báo lỗi nếu thất bại
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng popup
                },
                child: const Text('Đồng ý'),
              ),
            ],
          );
        },
      );
    });
  }
}
