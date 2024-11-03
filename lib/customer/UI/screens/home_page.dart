import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/auth/data/models/user_model.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/customer/UI/screens/create_order.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  double _logoHeight = 75.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final double offset = _scrollController.offset;
    setState(() {
      _logoHeight =
          75.0 - (offset * 0.5).clamp(0.0, 45.0); // Logo sẽ thu nhỏ nhiều hơn
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: double.parse("200") -
                    (_scrollController.hasClients
                            ? _scrollController.offset * 0.4
                            : 0)
                        .clamp(0.0, 80.0), // Thu nhỏ nhiều hơn
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(150),
                    bottomRight: Radius.circular(150),
                  ),
                ),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 70.0 -
                            (_scrollController.hasClients
                                    ? _scrollController.offset * 0.3
                                    : 0)
                                .clamp(0.0, 50.0),
                        left: 20,
                        right: 20,
                        bottom: 10),
                    child: Image.asset(
                      'lib/assets/logo.png',
                      height: _logoHeight,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      MyServices(
                        constraints: constraints,
                        user: widget.user,
                      ),
                      MyNotifications(constraints: constraints)
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MyNotifications extends StatelessWidget {
  final BoxConstraints constraints;

  const MyNotifications({
    super.key,
    required this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Các thông báo quan trọng",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_active_outlined,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              ListView.builder(
                padding: const EdgeInsets.only(top: 20),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      NotificationCard(noti: notifications[index]),
                      if (index < notifications.length - 1)
                        const SizedBox(height: 20)
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationModel noti;
  const NotificationCard({super.key, required this.noti});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => noti.destination),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            // Hình ảnh ở bên trái
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.asset(
                noti.image,
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ),
            ),
            // Nội dung thông báo
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      noti.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      noti.shortContent,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            // Nút "Chi tiết"
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => noti.destination),
                  );
                },
                child: const Text(
                  'Chi tiết',
                  style: TextStyle(color: Colors.blueAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationModel {
  final String name;
  final String shortContent;
  final String image;
  final Widget destination;

  NotificationModel({
    required this.name,
    required this.shortContent,
    required this.image,
    required this.destination,
  });
}

List<NotificationModel> notifications = [
  NotificationModel(
    name: "Thông báo 1",
    shortContent: "Đây là thông báo",
    image: "lib/assets/avt.jpg",
    destination: Container(),
  ),
  NotificationModel(
    name: "Thông báo 2",
    shortContent: "Đây là thông báo",
    image: "lib/assets/avt.jpg",
    destination: Container(),
  ),
  NotificationModel(
    name: "Thông báo 3",
    shortContent: "Đây là thông báo",
    image: "lib/assets/avt.jpg",
    destination: Container(),
  ),
];

class MyServices extends StatefulWidget {
  final User user;
  final BoxConstraints constraints;
  MyServices({super.key, required this.constraints, required this.user});

  @override
  State<MyServices> createState() => _MyServicesState();
}

class _MyServicesState extends State<MyServices> {
  final List<ServiceModel> services = [];

  @override
  void initState() {
    // TODO: implement initState
    services.add(
      ServiceModel(
        name: "Đặt hàng",
        iconPath: "lib/assets/avt.jpg",
        destination: CreateOrder(user: widget.user),
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Các dịch vụ của chúng tôi",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GridView.builder(
                padding: const EdgeInsets.only(top: 20),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.constraints.maxWidth > 600 ? 4 : 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: services.length,
                itemBuilder: (context, index) {
                  return ServiceCard(
                    service: services[index],
                    onTap: () {
                      // Xử lý khi nhấn vào dịch vụ
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => services[index].destination,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const ServiceCard({
    Key? key,
    required this.service,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                service.iconPath,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              service.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceModel {
  final String name;
  final String iconPath;
  final Widget destination;

  ServiceModel({
    required this.name,
    required this.iconPath,
    required this.destination,
  });
}
