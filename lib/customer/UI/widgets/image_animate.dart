import 'dart:async';
import 'package:flutter/material.dart';

class ImageSlideshow extends StatefulWidget {
  const ImageSlideshow({super.key});

  @override
  State<ImageSlideshow> createState() => _ImageSlideshowState();
}

class _ImageSlideshowState extends State<ImageSlideshow> {
  late Timer _timer;
  late PageController _pageController;
  int _currentPage = 0;

  // Danh sách các đường dẫn ảnh
  final List<String> _images = [
    'lib/assets/logo.png',
    'lib/assets/logo.png',
    'lib/assets/logo.png',
    'lib/assets/logo.png',
    'lib/assets/logo.png',
    // Thêm các ảnh khác vào đây
  ];

  @override
  void initState() {
    super.initState();

    // Khởi tạo PageController
    _pageController = PageController(initialPage: 0);

    // Đặt Timer để tự động chuyển trang sau mỗi 4 giây
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentPage < _images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Huỷ Timer khi widget bị huỷ
    _pageController.dispose(); // Huỷ PageController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: 200,
      width: MediaQuery.of(context).size.width - 40,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: PageView.builder(
        controller: _pageController,
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return Image.asset(
            _images[index],
            fit: BoxFit.cover,
          );
        },
      ),
    );
  }
}
