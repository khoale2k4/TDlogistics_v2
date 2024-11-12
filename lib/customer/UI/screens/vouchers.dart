import 'package:flutter/material.dart';

class Voucher {
  final String title;
  final String description;
  final String imageUrl;
  final String expiryDate;

  Voucher({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.expiryDate,
  });
}

class VoucherPage extends StatelessWidget {
  final List<Voucher> vouchers = [
    Voucher(
      title: 'Giảm giá 20%',
      description: 'Giảm 20% cho đơn hàng trên 500.000đ',
      imageUrl: 'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png',
      expiryDate: 'HSD: 31/12/2023',
    ),
    Voucher(
      title: 'Miễn phí vận chuyển',
      description: 'Miễn phí vận chuyển cho đơn hàng trên 300.000đ',
      imageUrl: 'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png',
      expiryDate: 'HSD: 15/11/2023',
    ),
    // Thêm nhiều voucher khác nếu cần
  ];

  VoucherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phiếu giảm giá'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.7,
          ),
          itemCount: vouchers.length,
          itemBuilder: (context, index) {
            final voucher = vouchers[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      voucher.imageUrl,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      voucher.title,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(voucher.description),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      voucher.expiryDate,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
