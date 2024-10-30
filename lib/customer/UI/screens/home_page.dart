import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/customer/UI/screens/create_order.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
                    children: List.generate(
                        4, (index) => MyServices(constraints: constraints)),
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

class MyServices extends StatelessWidget {
  final BoxConstraints constraints;
  const MyServices({super.key, required this.constraints});

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
                  crossAxisCount: constraints.maxWidth > 600 ? 4 : 3,
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

final List<ServiceModel> services = [
  ServiceModel(
    name: "Đặt hàng",
    iconPath: "lib/assets/avt.jpg",
    destination: const CreateOrder(),
  ),
];
