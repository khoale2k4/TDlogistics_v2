import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlogistic_v2/customer/bloc/order_bloc.dart';
import 'package:tdlogistic_v2/customer/bloc/order_event.dart';
import 'package:tdlogistic_v2/customer/bloc/order_state.dart';
import 'package:tdlogistic_v2/customer/data/models/voucher.dart';

class VoucherSelectionPage extends StatefulWidget {
  final String? voucher; 
  const VoucherSelectionPage({super.key, this.voucher});

  @override
  State<VoucherSelectionPage> createState() => _VoucherSelectionPageState();
}

class _VoucherSelectionPageState extends State<VoucherSelectionPage> {
  String? _selectedVoucher;

  @override
  void initState() {
    super.initState();
    _selectedVoucher = widget.voucher;
    context.read<GetVoucherBloc>().add(GetVouchers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr("order_pages.payment_page.voucher_selection"),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      body: BlocBuilder<GetVoucherBloc, OrderState>(
        builder: (context, state) {
          if (state is GettingPositions) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GotVouchers) {
            final vouchers = state.vouchers;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: vouchers.length,
                    itemBuilder: (context, index) {
                      final voucher = vouchers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading:
                              const Icon(Icons.local_offer, color: Colors.red),
                          title: Text(
                            voucher.id!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "${context.tr("order_pages.payment_page.discount")} ${voucher.discount} VNĐ",
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Checkbox(
                            value: _selectedVoucher == voucher.id,
                            onChanged: (bool? isSelected) {
                              setState(() {
                                _selectedVoucher =
                                    isSelected == true ? voucher.id : null;
                              });
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    VoucherDetailPage(voucher: voucher),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _selectedVoucher == null
                        ? null
                        : () {
                            Navigator.pop(context, _selectedVoucher);
                          },
                    child: Text(
                      context.tr("order_pages.payment_page.choose"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else if (state is GetChatWithShipFailure) {
            return Center(child: Text('Lỗi: ${state.error}'));
          }
          return const Center(child: Text('Không có dữ liệu'));
        },
      ),
    );
  }
}

class VoucherDetailPage extends StatelessWidget {
  final Voucher voucher;

  const VoucherDetailPage({Key? key, required this.voucher}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr("order_pages.payment_page.voucher_detail"),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voucher.id ?? "VOUCHER",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "${context.tr("order_pages.payment_page.discount")} ${voucher.discount} VNĐ",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
