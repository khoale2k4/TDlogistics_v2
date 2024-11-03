import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tdlogistic_v2/auth/data/models/user_model.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/core/service/contact_service.dart';
import 'package:tdlogistic_v2/customer/UI/screens/map2markers.dart';
import 'package:tdlogistic_v2/customer/bloc/order_bloc.dart';
import 'package:tdlogistic_v2/customer/bloc/order_event.dart';
import 'package:tdlogistic_v2/customer/bloc/order_state.dart';
import 'package:dvhcvn/dvhcvn.dart' as dvhcvn;
import 'package:tdlogistic_v2/customer/data/models/create_order.dart';

class CreateOrder extends StatefulWidget {
  final User user;
  const CreateOrder({super.key, required this.user});

  @override
  State<CreateOrder> createState() => _CreateOrderState();
}

class _CreateOrderState extends State<CreateOrder> {
  bool isCalculating = false;
  num fee = 0;
  double _buttonX = 350.0;
  double _buttonY = 120.0;
  late User user;

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
  final TextEditingController _orderDescriptionController =
      TextEditingController();

  List<Location> favoLocation = [];

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
  final _giftMessageController = TextEditingController();
  final _noteController = TextEditingController();
  int _giftTopic = 0;
  String? _selectedGoodsType;
  bool _isBulky = false;
  bool _isInsured = true;
  bool _isAGift = false;
  bool _isDoorToDoor = false;
  num _selectedWeightRange = 0;

  String _selectedDeliveryMethod = 'Giao hàng tiết kiệm';
  List<String> giftTopics = [
    "Ngày quốc tế Phụ nữ 8/3",
    "Ngày của mẹ",
    "Ngày phụ nữ Việt Nam 20/10",
    "Quà sinh nhật",
    "Tết",
    "Valentine",
    "Giáng sinh",
    "Ngày giáo viên"
  ];

  final List<String> _offers = [
    'Ưu đãi 1: Giảm 10%',
    'Ưu đãi 2: Miễn phí vận chuyển',
    'Ưu đãi 3: Giảm giá cho lần mua tiếp theo',
    'Ưu đãi 4: Tặng kèm sản phẩm',
  ];

  final List<bool> _selectedOffers = [false, false, false, false];

  void _onOfferSelected(int index, bool value) {
    setState(() {
      _selectedOffers[index] =
          value; // Cập nhật trạng thái khi người dùng chọn ưu đãi
    });
  }

  //////////////////////////////
  String _selectedPaymentMethod = "Tiền mặt";
  bool _senderWillPay = true;

  bool _validateNumberInputs() {
    return true;
  }

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _pageController = PageController(initialPage: 1);
    _senderNameController.text =
        "${user.firstName == null ? "" : user.firstName + " "}${user.lastName ?? ""}";
    _senderPhoneController.text = user.phoneNumber ?? "";
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
                    _buildPaymentPage(),
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
            bottom: _buttonY,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _buttonX += details.delta.dx;
                  _buttonY -= details.delta.dy;
                });
              },
              child: FloatingActionButton(
                backgroundColor: Colors.lightBlue.shade100,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Map2Markers(
                        startAddress:
                            "${_senderAddressController.text} ${_senderWardController.text} ${_senderDistrictController.text} ${_senderCityController.text}",
                        endAddress:
                            "${_receiverAddressController.text} ${_receiverWardController.text} ${_receiverDistrictController.text} ${_receiverCityController.text}",
                      ),
                    ),
                  );
                },
                child: const Icon(Icons.place, color: Colors.green, size: 40),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Thông tin người gửi', button: true),
            const SizedBox(height: 10),
            _buildTextField(
              controller: _senderNameController,
              labelText: 'Tên người gửi',
              isValid: _isSenderNameValid,
              icon: Icons.person,
              onChanged: (value) {
                setState(() {
                  _isSenderNameValid = true;
                });
              },
              fromContacts: true,
            ),
            _buildTextField(
              controller: _senderPhoneController,
              labelText: 'Số điện thoại',
              isValid: _isSenderPhoneValid,
              icon: Icons.phone,
              onChanged: (value) {
                setState(() {
                  _isSenderPhoneValid = true;
                });
              },
            ),
            _buildDropdown(
              items: (dvhcvn.level1s.map((level) => level.name).toList()
                ..insert(0, "Vui lòng chọn tỉnh thành")),
              selectedValue: _senderCityController.text.isNotEmpty
                  ? _senderCityController.text
                  : null,
              labelText: 'Tỉnh thành',
              isValid: _isSenderCityValid,
              icon: Icons.location_city,
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
                icon: Icons.map,
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
                icon: Icons.location_on,
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
                icon: Icons.home,
                onChanged: (value) {
                  setState(() {
                    _isSenderAddressValid = true;
                  });
                },
                addToFavo: true),
            const SizedBox(height: 20),
            _buildSectionTitle('Thông tin người nhận',
                button: true, sender: false),
            const SizedBox(height: 10),
            _buildTextField(
                controller: _receiverNameController,
                labelText: 'Tên người nhận',
                isValid: _isReceiverNameValid,
                icon: Icons.person,
                onChanged: (value) {
                  setState(() {
                    _isReceiverNameValid = true;
                  });
                },
                fromContacts: true,
                isSender: false),
            _buildTextField(
              controller: _receiverPhoneController,
              labelText: 'Số điện thoại',
              isValid: _isReceiverPhoneValid,
              icon: Icons.phone,
              onChanged: (value) {
                setState(() {
                  _isReceiverPhoneValid = true;
                });
              },
            ),
            _buildDropdown(
              items: (dvhcvn.level1s.map((level) => level.name).toList()
                ..insert(0, "Vui lòng chọn tỉnh thành")),
              selectedValue: _receiverCityController.text.isNotEmpty
                  ? _receiverCityController.text
                  : null,
              labelText: 'Tỉnh thành',
              isValid: _isReceiverCityValid,
              icon: Icons.location_city,
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
                icon: Icons.map,
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
                icon: Icons.location_on,
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
                icon: Icons.home,
                onChanged: (value) {
                  setState(() {
                    _isReceiverAddressValid = true;
                  });
                },
                addToFavo: true),
            _buildSectionTitle('Ghi chú cho shipper'),
            _buildTextField(
                controller: _orderDescriptionController,
                labelText: 'Mô tả đơn hàng',
                isValid: true,
                icon: Icons.description,
                onChanged: (value) {
                  setState(() {});
                },
                isDes: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title,
      {bool button = false, bool sender = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          if (button) ...[
            Expanded(child: Container()),
            TextButton(
              onPressed: () {
                showBottomSelectPopup(
                    context: context, options: favoLocation, isSender: sender);
              },
              child: const Text("Ưa thích"),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField(
      {required TextEditingController controller,
      required String labelText,
      required bool isValid,
      required ValueChanged<String?> onChanged,
      required IconData icon,
      bool isDes = false,
      bool fromContacts = false,
      bool isSender = true,
      bool addToFavo = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        maxLines: isDes ? 3 : 1,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade100,
          labelText: labelText,
          labelStyle: TextStyle(
            color: isValid ? Colors.grey.shade700 : Colors.red,
          ),
          errorText: isValid ? null : 'Vui lòng nhập $labelText',
          prefixIcon:
              Icon(icon, color: isValid ? Colors.grey.shade700 : Colors.red),
          suffixIcon: fromContacts
              ? IconButton(
                  onPressed: () async {
                    List<String?> namePhone = await pickFullnameAndPhone();
                    if (namePhone.length == 2 &&
                        namePhone[0] != null &&
                        namePhone[1] != null) {
                      setState(() {
                        if (isSender) {
                          _senderNameController.text = namePhone[0]!;
                          _senderPhoneController.text = namePhone[1]!;
                        } else {
                          _receiverNameController.text = namePhone[0]!;
                          _receiverPhoneController.text = namePhone[1]!;
                        }
                      });
                    }
                  },
                  icon: const Icon(Icons.contact_phone),
                )
              : addToFavo
                  ? IconButton(
                      onPressed: () async {
                        if (isSender) {
                          if (_senderNameController.text != "" &&
                              _senderPhoneController.text != "" &&
                              _senderCityController.text != "" &&
                              _senderDistrictController.text != "" &&
                              _senderCityController.text != "") {
                            String name = await getName();
                            print(name);
                            if (name == "") return;
                            setState(() {
                              favoLocation.add(
                                Location(
                                    fullName: _senderNameController.text,
                                    phone: _senderPhoneController.text,
                                    name: name,
                                    address: _senderAddressController.text,
                                    district: _senderDistrictController.text,
                                    province: _senderCityController.text,
                                    ward: _senderWardController.text),
                              );
                            });
                          }
                        } else {
                          if (_receiverNameController.text != "" &&
                              _receiverPhoneController.text != "" &&
                              _receiverCityController.text != "" &&
                              _receiverDistrictController.text != "" &&
                              _receiverCityController.text != "") {
                            String name = await getName();
                            if (name == "") return;
                            setState(() {
                              favoLocation.add(
                                Location(
                                    name: name,
                                    fullName: _receiverNameController.text,
                                    phone: _receiverPhoneController.text,
                                    address: _receiverAddressController.text,
                                    district: _receiverDistrictController.text,
                                    province: _receiverCityController.text,
                                    ward: _receiverWardController.text),
                              );
                            });
                          }
                        }
                      },
                      icon: const Icon(Icons.favorite),
                    )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Future<String> getName() async {
    String name = await showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = "";
        return AlertDialog(
          title: const Text('Tạo địa chỉ yêu thích'),
          content: TextField(
            onChanged: (value) {
              name = value;
            },
            decoration: const InputDecoration(hintText: "Nhập tên"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                name = "";
                Navigator.of(context).pop(name);
              },
            ),
            TextButton(
              child: const Text('Xác nhận'),
              onPressed: () {
                Navigator.of(context).pop(name);
              },
            ),
          ],
        );
      },
    );
    return name;
  }

  Future<void> showBottomSelectPopup({
    required BuildContext context,
    required List<Location> options,
    bool isSender = true,
  }) async {
    final size = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            height: size * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar giữ nguyên
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header với Flexible để tránh overflow
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Địa điểm ưa thích',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // List view với Expanded
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      bottom: bottomPadding + 16,
                      left: 16,
                      right: 16,
                    ),
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options[index];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(top: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              if (isSender) {
                                _senderCityController.text = option.province;
                                _senderDistrictController.text =
                                    option.district;
                                _senderWardController.text = option.ward;
                                _senderAddressController.text = option.address;
                              } else {
                                _receiverCityController.text = option.province;
                                _receiverDistrictController.text =
                                    option.district;
                                _receiverWardController.text = option.ward;
                                _receiverAddressController.text =
                                    option.address;
                              }
                              Navigator.pop(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[200]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    option.getPersong(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    option.getAddress(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdown({
    required String labelText,
    required List<String> items,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
    required bool isValid,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        onChanged: onChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade100,
          labelText: labelText,
          labelStyle: TextStyle(
            color: isValid ? Colors.grey.shade700 : Colors.red,
          ),
          errorText: isValid ? null : 'Vui lòng chọn $labelText',
          prefixIcon:
              Icon(icon, color: isValid ? Colors.grey.shade700 : Colors.red),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        hint: Text(
          'Chọn một $labelText',
          style: TextStyle(color: Colors.grey.shade500),
        ),
        dropdownColor: Colors.white,
        iconEnabledColor: Colors.blue,
        iconSize: 28,
      ),
    );
  }

  Widget _buildNumberInputPage() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.only(top: 50.0, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nhập thông tin gói hàng:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 30),

            // Trường nhập số tiền thu hộ (không cần kiểm tra hợp lệ)
            _buildNumberField(
              controller: _cashOnDeliveryController,
              labelText: 'Số tiền thu hộ (VNĐ)',
              hintText: 'Nhập số tiền',
              isEmpty: true,
            ),
            const SizedBox(height: 20),

            // Lưới nút chọn khối lượng
            const Text(
              'Chọn khối lượng (kg):',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < 8; i++)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedWeightRange = i;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: _selectedWeightRange == i
                                ? Colors.black
                                : Colors.transparent),
                        borderRadius:
                            BorderRadius.circular(10), // Set border radius here
                      ),
                    ),
                    child: Text(
                      '${i * 5}-${(i + 1) * 5} kg',
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  )
              ],
            ),
            const SizedBox(height: 20),

            // Lưới nút chọn loại hàng hoá
            const Text(
              'Chọn loại hàng hoá:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var type in [
                  'Hàng dễ vỡ',
                  'Thực phẩm',
                  'Quần áo',
                  'Sách',
                  'Đồ điện tử'
                ])
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedGoodsType = type;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: _selectedGoodsType == type
                                ? Colors.black
                                : Colors.transparent),
                        borderRadius:
                            BorderRadius.circular(10), // Set border radius here
                      ),
                    ),
                    child: Text(
                      type,
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _buildToggleButton(
              title: 'Hàng cồng kềnh',
              isSelected: _isBulky,
              callBack: (bool value) {
                setState(() {
                  _isBulky = value;
                });
              },
              description: '60 x 70 x 60cm, tối đa 50kg',
            ),
            const SizedBox(height: 20),
            _buildToggleButton(
              title: 'Mua bảo hiểm',
              isSelected: _isInsured,
              callBack: (bool value) {
                setState(() {
                  _isInsured =
                      value; // Cập nhật trạng thái khi người dùng thay đổi toggle
                });
              },
              description:
                  'Bảo hiểm giúp bảo vệ đơn hàng của bạn trong trường hợp hư hỏng hoặc mất mát.',
            ),
            const SizedBox(height: 20),
            _buildToggleButton(
              title: 'Đơn hàng quà tặng',
              isSelected: _isAGift,
              callBack: (bool value) {
                setState(() {
                  _isAGift = value;
                });
              },
              description: 'Quà tặng bạn bè, người thân',
            ),
            if (_isAGift) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < 8; i++)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _giftTopic = i;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade200,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: _giftTopic == i
                                  ? Colors.black
                                  : Colors.transparent),
                          borderRadius: BorderRadius.circular(
                              10), // Set border radius here
                        ),
                      ),
                      child: Text(
                        giftTopics[i],
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    )
                ],
              ),
              _buildTextField(
                  controller: _giftMessageController,
                  labelText: "Lời nhắn",
                  isValid: true,
                  onChanged: (value) {
                    if (value != null) _giftMessageController.text = value;
                  },
                  icon: Icons.message,
                  isDes: true),
            ],

            const SizedBox(height: 20),
            _buildToggleButton(
              title: 'Giao tận cửa',
              isSelected: _isDoorToDoor,
              callBack: (bool value) {
                setState(() {
                  _isDoorToDoor = value;
                });
              },
              description: 'Giao đến cửa người nhận.',
            ),
            const SizedBox(height: 20),
            // Dropdown cho phương thức giao
            _buildDeliveryMethodSelector(),
            _buildTextField(
                controller: _noteController,
                labelText: "Ghi chú",
                isValid: true,
                onChanged: (value) {
                  setState(() {});
                },
                icon: Icons.pending_actions,
                isDes: true),
            // Container(
            //   height: 300,
            //   margin: const EdgeInsets.symmetric(horizontal: 16),
            //   decoration: BoxDecoration(
            //     color: Colors.white,
            //     borderRadius: BorderRadius.circular(12),
            //     boxShadow: [
            //       BoxShadow(
            //         color: Colors.grey.withOpacity(0.1),
            //         spreadRadius: 2,
            //         blurRadius: 8,
            //         offset: const Offset(0, 2),
            //       ),
            //     ],
            //   ),
            //   child: ListView.separated(
            //     padding: const EdgeInsets.all(16),
            //     itemCount: _offers.length,
            //     separatorBuilder: (context, index) => const Divider(height: 1),
            //     itemBuilder: (context, index) {
            //       return AnimatedContainer(
            //         duration: const Duration(milliseconds: 200),
            //         decoration: BoxDecoration(
            //           color: _selectedOffers[index]
            //               ? Colors.blue.withOpacity(0.1)
            //               : Colors.transparent,
            //           borderRadius: BorderRadius.circular(8),
            //         ),
            //         child: ListTile(
            //           contentPadding:
            //               const EdgeInsets.symmetric(horizontal: 12),
            //           leading: Container(
            //             width: 24,
            //             height: 24,
            //             decoration: BoxDecoration(
            //               shape: BoxShape.circle,
            //               border: Border.all(
            //                 color: _selectedOffers[index]
            //                     ? Colors.blue
            //                     : Colors.grey,
            //                 width: 2,
            //               ),
            //               color: _selectedOffers[index]
            //                   ? Colors.blue
            //                   : Colors.white,
            //             ),
            //             child: _selectedOffers[index]
            //                 ? const Icon(Icons.check,
            //                     size: 16, color: Colors.white)
            //                 : null,
            //           ),
            //           title: Text(
            //             _offers[index],
            //             style: TextStyle(
            //               fontSize: 16,
            //               fontWeight: _selectedOffers[index]
            //                   ? FontWeight.bold
            //                   : FontWeight.normal,
            //             ),
            //           ),
            //           onTap: () =>
            //               _onOfferSelected(index, !_selectedOffers[index]),
            //         ),
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton({
    required String title,
    required bool isSelected,
    required Function(bool) callBack,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Switch(
              value: isSelected,
              activeColor: mainColor,
              onChanged: (value) {
                callBack(value); // Gọi callback với giá trị mới
              },
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          description,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
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
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blue, width: 1.5),
        ),
        labelText: labelText,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade500),
        errorText: isEmpty ? null : 'Vui lòng nhập $labelText',
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
    );
  }

  Widget _buildDeliveryMethodSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: DropdownButtonFormField<String>(
        value: _selectedDeliveryMethod,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade100,
          labelText: 'Phương thức giao',
          labelStyle: TextStyle(color: Colors.grey.shade700),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.blue, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        items: ['Giao hàng nhanh', 'Giao hàng tiết kiệm'].map((String method) {
          return DropdownMenuItem<String>(
            value: method,
            child: Text(method),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) _selectedDeliveryMethod = value;
        },
        hint: Text(
          'Chọn phương thức giao',
          style: TextStyle(color: Colors.grey.shade500),
        ),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
        iconSize: 28,
      ),
    );
  }

  Widget _buildPaymentPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Thông tin thanh toán'),
            _buildDropdown(
              items: ['Chuyển khoản', 'Tiền mặt', 'Ví điện tử'],
              selectedValue: _selectedPaymentMethod,
              labelText: 'Phương thức thanh toán',
              isValid: true,
              icon: Icons.payment,
              onChanged: (value) {
                setState(() {
                  if (value != null) _selectedPaymentMethod = value;
                });
              },
            ),
            const SizedBox(height: 20),
            _buildToggleButton(
              title: 'Người gửi trả tiền',
              isSelected: _senderWillPay,
              callBack: (bool value) {
                setState(() {
                  _senderWillPay = value;
                });
              },
              description: '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmPage(BuildContext context) {
    return BlocListener<CreateOrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderCreated) {
            // Hiển thị dialog khi tạo đơn hàng thành công
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Thành công'),
                  content: const Text('Đơn hàng đã được tạo thành công!'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Đóng dialog
                        // Có thể thêm navigation về trang chủ hoặc trang đơn hàng ở đây
                      },
                      child: const Text('Đóng'),
                    ),
                  ],
                );
              },
            );
          } else if (state is OrderCreateFaild) {
            // Hiển thị dialog khi tạo đơn hàng thất bại
            showDialog(
              context: context,
              barrierDismissible:
                  false, // Không cho phép đóng dialog bằng cách chạm bên ngoài
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Thất bại'),
                  content: Text('Không thể tạo đơn hàng: ${state.error}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Thử lại'),
                    ),
                  ],
                );
              },
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Center(
                    child: Text(
                      "Xác nhận đơn hàng",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildInfoCard(
                    'Thông tin người gửi',
                    Icons.person_outline,
                    [
                      _buildInfoRow('Họ và tên', _senderNameController.text),
                      _buildInfoRow('Địa chỉ', _senderAddressController.text),
                      _buildInfoRow('Phường/Xã', _senderWardController.text),
                      _buildInfoRow(
                          'Quận/Huyện', _senderDistrictController.text),
                      _buildInfoRow('Thành phố', _senderCityController.text),
                      _buildInfoRow('Điện thoại', _senderPhoneController.text),
                      _buildInfoRow(
                          'Ghi chú',
                          (_orderDescriptionController.text == ""
                              ? "Không có"
                              : _orderDescriptionController.text)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    'Thông tin người nhận',
                    Icons.person_pin_circle_outlined,
                    [
                      _buildInfoRow('Họ và tên', _receiverNameController.text),
                      _buildInfoRow('Địa chỉ', _receiverAddressController.text),
                      _buildInfoRow('Phường/Xã', _receiverWardController.text),
                      _buildInfoRow(
                          'Quận/Huyện', _receiverDistrictController.text),
                      _buildInfoRow('Thành phố', _receiverCityController.text),
                      _buildInfoRow(
                          'Điện thoại', _receiverPhoneController.text),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    'Thông tin gói hàng',
                    Icons.inventory_2_outlined,
                    [
                      _buildInfoRow('Thu hộ (COD)',
                          '${_cashOnDeliveryController.text} VNĐ'),
                      // _buildInfoRow('Kích thước',
                      //     '${_lengthController.text}x${_widthController.text}x${_heightController.text} cm'),
                      _buildInfoRow('Cân nặng',
                          '${_selectedWeightRange * 5}-${(_selectedWeightRange + 1) * 5} kg'),
                      _buildInfoRow(
                          'Loại hàng', _selectedGoodsType ?? "Bất kì"),
                      BlocBuilder<OrderBlocFee, OrderState>(
                        builder: (context, state) {
                          return _buildInfoRow(
                              'Chi phí giao hàng',
                              state is OrderFeeCalculated
                                  ? '${state.fee} VND'
                                  : state is OrderFeeCalculating
                                      ? 'Đang tính...'
                                      : 'Chưa tính phí');
                        },
                      ),
                      if (_isAGift) ...[
                        _buildInfoRow('Đơn quà', giftTopics[_giftTopic]),
                        _buildInfoRow('Lời nhắn', _giftMessageController.text),
                      ]
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoCard(
                    'Thông tin đơn hàng',
                    Icons.description_outlined,
                    [
                      _buildInfoRow(
                          'Phương thức giao', _selectedDeliveryMethod),
                      _buildInfoRow('Phương thức thanh toán',
                          _selectedPaymentMethod ?? 'Chưa chọn'),
                      _buildInfoRow('Bảo hiểm', _isInsured ? 'Có' : 'Không'),
                      // _buildInfoRow('Ưu đãi', _isDiscountApplied ? 'Có' : 'Không'),
                      _buildInfoRow(
                          "Đơn hàng cồng kềnh", _isBulky ? "Có" : "Không"),
                      _buildInfoRow(
                          'Mô tả',
                          (_noteController.text == ""
                              ? "Không có"
                              : _noteController.text)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocBuilder<CreateOrderBloc, OrderState>(
              builder: (context, state) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: state is OrderCreating
                      ? null
                      : () => handleNewOrder(context),
                  child: state is OrderCreating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Xác nhận và tạo đơn hàng',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
        ));
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
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
        // if (_currentPage >= 1 && _currentPage <= 2) _buildClearButton(),
        if (_currentPage == 4)
          ElevatedButton.icon(
            onPressed: () {
              // Gọi phương thức chia sẻ
              Share.share("abcde");
            },
            icon: const Icon(Icons.share),
            label: const Text("Chia sẻ"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        if (_currentPage > 0 && _currentPage < 4)
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
                  // context.read<OrderBlocFee>().add(
                  //       CalculateFee(
                  //         _senderCityController.text,
                  //         _senderDistrictController.text,
                  //         _senderAddressController.text,
                  //         _receiverCityController.text,
                  //         _receiverDistrictController.text,
                  //         _receiverAddressController.text,
                  //         _selectedDeliveryMethod,
                  //         int.parse(_heightController.text),
                  //         int.parse(_lengthController.text),
                  //         int.parse(_weightController.text),
                  //         int.parse(_widthController.text),
                  //       ),
                  //     );
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

class Location {
  String fullName;
  String name;
  String phone;
  String address;
  String ward;
  String district;
  String province;

  Location(
      {required this.fullName,
      required this.name,
      required this.phone,
      required this.address,
      required this.district,
      required this.ward,
      required this.province});

  String getPersong() {
    return "$fullName: $phone";
  }

  String getAddress() {
    return '$address, $ward, $district, $province';
  }

  Location toLocation(String fn, String nam, String phone, String add,
      String wa, String dis, String pro) {
    return Location(
        fullName: fn,
        name: nam,
        phone: phone,
        address: add,
        district: dis,
        province: pro,
        ward: wa);
  }
}
