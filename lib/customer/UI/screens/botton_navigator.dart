import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/auth/data/models/user_model.dart';
import 'package:tdlogistic_v2/customer/UI/screens/contact/chats_screen.dart';
import 'package:tdlogistic_v2/customer/UI/screens/create%20order/create_order.dart';
import 'package:tdlogistic_v2/customer/UI/screens/cus_info.dart';
import 'package:tdlogistic_v2/customer/UI/screens/history.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/customer/UI/screens/home_page.dart';

class NavigatePage extends StatefulWidget {
  final User user;
  final Function(String, String) sendMessage;
  final int start;
  const NavigatePage(
      {super.key,
      required this.user,
      required this.sendMessage,
      required this.start});

  @override
  _NavigatePageState createState() => _NavigatePageState();
}

class _NavigatePageState extends State<NavigatePage> {
  int _currentIndex = 0;
  int _currentFeature = 0;
  late List<Widget> _pages;
  late List<Widget> _features;

  @override
  void initState() {
    super.initState();
    _features = [
      HomePage(user: widget.user, toFeature: toFeature),
      CreateOrder(user: widget.user, toHome: toHome)
    ];
    _pages = [
      Container(),
      History(sendMessage: widget.sendMessage),
      ChatListScreen(
        sendMessage: widget.sendMessage,
      ),
      CustomerInfor(user: widget.user), // Truyền user vào CustomerInfor
    ];
    _currentIndex = widget.start;
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Hàm cập nhật trang khi chọn tab khác
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void toHome() {
    setState(() {
      _currentFeature = 0;
    });
  }

  void toFeature(int feature) {
    setState(() {
      _currentFeature = feature;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _features[_currentFeature], // Tab Home
          _buildHistory(), // Tab History
          _buildChatList(), // Tab Chat
          _buildCustomerInfo(), // Tab Profile
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex, // Vị trí hiện tại
        onTap: onTabTapped, // Gọi hàm khi tab được nhấn
        items: [
          BottomNavigationBarItem(
            icon: _buildIconWithCircle(Icons.home, 0),
            label: context.tr("nav_bar.home"),
          ),
          BottomNavigationBarItem(
            icon: _buildIconWithCircle(Icons.history, 1),
            label: context.tr('nav_bar.history'),
          ),
          BottomNavigationBarItem(
            icon: _buildIconWithCircle(Icons.messenger_outline, 2),
            label: context.tr('nav_bar.chat'),
          ),
          // BottomNavigationBarItem(
          //   icon: _buildIconWithCircle(Icons.notifications_active_outlined, 2),
          //   label: 'Thông báo',
          // ),
          BottomNavigationBarItem(
            icon: _buildIconWithCircle(Icons.person, 3),
            label: context.tr('nav_bar.me'),
          ),
        ],
        type: BottomNavigationBarType.fixed, // Đảm bảo các tab không bị cuộn
      ),
    );
  }

  Widget _buildIconWithCircle(IconData icon, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // Thời gian chuyển đổi
      decoration: _currentIndex == index
          ? BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.shade100, // Màu nền cho tab được chọn
            )
          : null,
      padding: const EdgeInsets.all(8), // Khoảng cách xung quanh icon
      child: Icon(
        icon,
        size: _currentIndex == index
            ? 35
            : 24, // Kích thước lớn hơn cho icon được chọn
        color: _currentIndex == index
            ? mainColor
            : Colors.grey, // Màu icon khi được chọn
      ),
    );
  }

  Widget _buildHistory() {
    return _currentIndex == 1
        ? History(sendMessage: widget.sendMessage) // Chỉ build nếu index == 1
        : Container(); // Trả về Container rỗng nếu không phải tab History
  }

  Widget _buildChatList() {
    return _currentIndex == 2
        ? ChatListScreen(
            sendMessage: widget.sendMessage) // Chỉ build nếu index == 2
        : Container(); // Trả về Container rỗng nếu không phải tab Chat
  }

  Widget _buildCustomerInfo() {
    return _currentIndex == 3
        ? CustomerInfor(user: widget.user) // Chỉ build nếu index == 3
        : Container(); // Trả về Container rỗng nếu không phải tab Profile
  }
}
