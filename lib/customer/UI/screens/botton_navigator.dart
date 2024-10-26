import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/auth/data/models/user_model.dart';
import 'package:tdlogistic_v2/customer/UI/screens/chat_box.dart';
import 'package:tdlogistic_v2/customer/UI/screens/create_order.dart';
import 'package:tdlogistic_v2/customer/UI/screens/cus_info.dart';
import 'package:tdlogistic_v2/customer/UI/screens/history.dart';
import 'package:tdlogistic_v2/core/constant.dart';

class NavigatePage extends StatefulWidget {
  final User user;
  const NavigatePage({super.key, required this.user});

  @override
  _NavigatePageState createState() => _NavigatePageState();
}

class _NavigatePageState extends State<NavigatePage> {
  int _currentIndex = 0; // Index hiện tại của bottom navigation
  late User user; // Sử dụng late để đảm bảo user được khởi tạo

  @override
  void initState() {
    super.initState();
    user = widget.user; // Khởi tạo user từ widget
    _pages = [
      const CreateOrder(),
      const History(),
      const ChatBox(),
      CustomerInfor(user: user), // Truyền user vào CustomerInfor
    ];
  }

  late List<Widget> _pages;

  // Hàm cập nhật trang khi chọn tab khác
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex, // Hiển thị trang dựa trên chỉ số hiện tại
        children: _pages, // Lưu trạng thái các trang
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex, // Vị trí hiện tại
        onTap: onTabTapped, // Gọi hàm khi tab được nhấn
        items: [
          BottomNavigationBarItem(
            icon: _buildIconWithCircle(Icons.home, 0),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: _buildIconWithCircle(Icons.history, 1),
            label: 'Lịch sử',
          ),
          // BottomNavigationBarItem(
          //   icon: _buildIconWithCircle(Icons.map, 2),
          //   label: 'Bản đồ',
          // ),
          BottomNavigationBarItem(
            icon: _buildIconWithCircle(Icons.message, 2),
            label: 'Tin nhắn',
          ),
          BottomNavigationBarItem(
            icon: _buildIconWithCircle(Icons.person, 3),
            label: 'Bạn',
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
        size: _currentIndex == index ? 35 : 24, // Kích thước lớn hơn cho icon được chọn
        color: _currentIndex == index ? mainColor : Colors.grey, // Màu icon khi được chọn
      ),
    );
  }
}
