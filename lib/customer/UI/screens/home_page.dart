import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/auth/data/models/user_model.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/customer/UI/screens/create%20order/create_order.dart';

class HomePage extends StatefulWidget {
  final User user;
  final Function(int) toFeature;
  const HomePage({super.key, required this.user, required this.toFeature});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    print(widget.user.toJson());
    _scrollController.addListener(_onScroll);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400), // Tốc độ của hiệu ứng
    )..repeat(reverse: true); // Lặp lại hiệu ứng

    _animation = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  final ScrollController _scrollController = ScrollController();
  double _logoHeight = 75.0;

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final double offset = _scrollController.offset;
    setState(() {
      _logoHeight = 75.0 - (offset * 0.05).clamp(0.0, 45.0);
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
              // App header with animated logo
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 200.0 -
                    (_scrollController.hasClients
                            ? _scrollController.offset * 0.4
                            : 0)
                        .clamp(0.0, 80.0),
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
                    child: Container(
                      child: Image.asset(
                        'lib/assets/logo.png',
                        height: _logoHeight,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildPromotionsSection(),
                      const SizedBox(height: 20),
                      _buildNewsSection(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _animation.value),
            child: FloatingActionButton(
              onPressed: () {
                widget.toFeature(1);
              },
              backgroundColor: secondColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_rounded, color: Colors.black),
                  Text(context.tr("home.orderNow"), style: const TextStyle(fontSize: 10, color: Colors.black)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Phần khuyến mãi lướt ngang
  Widget _buildPromotionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            context.tr('home.voucher'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 4, // Số lượng khuyến mãi (ví dụ là 5)
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: _buildPromotionCard(index),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPromotionCard(int index) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
              child: Container(
                width: double
                    .infinity, // Để ảnh bao phủ toàn bộ chiều ngang của Container
                height: 400, // Chiều cao của Container tùy ý
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(15), // Tạo bo góc (nếu cần)
                ),
                clipBehavior: Clip.hardEdge, // Giúp ảnh cắt theo bo góc
                child: Image.asset(
                  'lib/assets/ads$index.jpg',
                  fit: BoxFit.cover, // Để ảnh bao phủ hết Container
                ),
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Text(
          //     'Giảm giá ${10 * (index + 1)}%',
          //     style: const TextStyle(
          //       fontWeight: FontWeight.bold,
          //       fontSize: 16,
          //       color: mainColor,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  List<String> images = [];

  List<String> titles = [
    "Ông Nguyễn Thanh Nam có đơn xin từ nhiệm vị trí Chủ tịch Hội đồng quản trị Viettel Post với lý do cá nhân.",
    "Cổ phiếu Viettel Post tăng kịch trần trong phiên chào sàn HOSE",
    "Cổ phiếu VTP (Viettel Post) tăng kịch biên độ trong phiên chào sàn HoSE",
    "Cổ phiếu “họ Viettel” tăng mạnh trước thềm Viettel Post (VTP) chuyển sàn sang HoSE",
  ];

  List<String> des = [
    "Ngày 17/8 vừa qua, ông Nguyễn Thanh Nam, Chủ tịch Hội đồng quản trị Tổng Công ty cổ phần Bưu chính Viettel (Viettel Post, mã VTP) đã có đơn xin từ nhiệm.",
    "Ngày 12/3/2024, Sở Giao dịch Chứng khoán TP. Hồ Chí Minh tổ chức Lễ trao quyết định niêm yết cho Tổng Công ty Cổ phần Bưu chính Viettel - Viettel Post (Mã chứng khoán: VTP) và đưa vào giao dịch chính thức 121.783.042 cổ phiếu VTP với tổng giá trị niêm yết hơn 1.217 tỷ đồng.",
    "Ngoài VTP tăng kịch biên độ trong phiên giao dịch đầu tiên trên HoSE, các cổ phiếu khác \"họ Viettel\" cũng tăng mạnh.",
    "Ngày mai (12/3), Viettel Post (mã VTP) sẽ chào sàn HoSE với mức giá tham chiếu 65.400 đồng/cổ phiếu. Phiên ngày 11/3, các cổ phiếu “họ Viettel” như VGI, CTR, VTK đều tăng mạnh trên HoSE, UPCOM, trong đó, CTR thậm chí tăng kịch trần."
  ];

  // Phần bài báo
  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            context.tr("home.news"),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4, // Số lượng bài báo (ví dụ là 5)
          itemBuilder: (context, index) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _buildNewsArticleCard(index),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNewsArticleCard(int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey.shade200, // Màu nền khi ảnh không tải được
                child: Image.asset(
                  'lib/assets/p${index + 1}.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 50,
                    ); // Biểu tượng khi ảnh không tải được
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titles[index],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    des[index],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
