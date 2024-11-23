import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlogistic_v2/core/models/order_model.dart';
import 'package:tdlogistic_v2/customer/UI/screens/map2markers.dart';
import 'package:tdlogistic_v2/customer/UI/screens/map_widget.dart';
import 'package:tdlogistic_v2/customer/bloc/order_bloc.dart';
import 'package:tdlogistic_v2/customer/bloc/order_event.dart';
import 'package:tdlogistic_v2/customer/bloc/order_state.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:share_plus/share_plus.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      // Call API based on the selected tab index
      final status = _getOrderStatusByIndex(_tabController.index);
      // context.read<OrderBlocSearchCus>().add(FetchOrdersByStatus(status));
    }
  }

  String _getOrderStatusByIndex(int index) {
    switch (index) {
      case 0:
        return 'processing';
      case 1:
        return 'shipping';
      case 2:
        return 'delivering';
      case 3:
        return 'cancelled';
      case 4:
        return 'completed';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: mainColor,
        title: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(0),
                      child: Image.asset(
                        'lib/assets/logo.png',
                        height: 75,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: Colors.black,
          ),
          tabs: const [
            Tab(text: "Đang xử lý"),
            Tab(text: "Đang gửi hàng"),
            Tab(text: "Đang giao hàng"),
            Tab(text: "Đã hoàn thành"),
            Tab(text: "Đã huỷ"),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: TabBarView(
        controller: _tabController,
        children: const [
          ProcessingOrdersTab(),
          TakingOrdersTab(),
          DeliveringOrdersTab(),
          CompletedOrdersTab(),
          CancelledOrdersTab(),
        ],
      ),
    );
  }
}

class ProcessingOrdersTab extends StatefulWidget {
  const ProcessingOrdersTab({super.key});

  @override
  State<ProcessingOrdersTab> createState() => _ProcessingOrdersTabState();
}

class _ProcessingOrdersTabState extends State<ProcessingOrdersTab> {
  List<Order> orders = [];

  int page = 1;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    context.read<ProcessingOrderBloc>().add(StartOrder());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProcessingOrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderLoaded) {
          setState(() {
            isLoadingMore = false;
            if (page == 1) {
              orders = state.orders;
            } else {
              orders.addAll(state.orders);
            }
          });
        }
      },
      child: Column(
        children: [
          Expanded(
            child: OrderListView(
              orders: orders,
              refreshFunc: () async {
                context.read<ProcessingOrderBloc>().add(StartOrder());
                page = 1;
              },
              loadMoreFunc: () async {
                if (!isLoadingMore) {
                  setState(() {
                    isLoadingMore = true;
                  });
                  page++;
                  context
                      .read<ProcessingOrderBloc>()
                      .add(AddOrder(const [], page));
                }
              },
              loading: isLoadingMore,
            ),
          ),
        ],
      ),
    );
  }
}

class TakingOrdersTab extends StatefulWidget {
  const TakingOrdersTab({super.key});

  @override
  State<TakingOrdersTab> createState() => _TakingOrdersTabState();
}

class _TakingOrdersTabState extends State<TakingOrdersTab> {
  List<Order> orders = [];
  int page = 1;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    context.read<TakingOrderBloc>().add(StartOrder());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TakingOrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderLoaded) {
          setState(() {
            isLoadingMore = false;
            if (page == 1) {
              orders = state.orders;
            } else {
              orders.addAll(state.orders);
            }
          });
        }
      },
      child: Column(
        children: [
          Expanded(
            child: OrderListView(
              orders: orders,
              refreshFunc: () async {
                context.read<TakingOrderBloc>().add(StartOrder());

                page = 1;
              },
              loadMoreFunc: () async {
                if (!isLoadingMore) {
                  setState(() {
                    isLoadingMore = true;
                  });
                  page++;
                  context.read<TakingOrderBloc>().add(AddOrder(const [], page));
                }
              },
              loading: isLoadingMore,
            ),
          ),
        ],
      ),
    );
  }
}

class DeliveringOrdersTab extends StatefulWidget {
  const DeliveringOrdersTab({super.key});

  @override
  State<DeliveringOrdersTab> createState() => _DeliveringOrdersTabState();
}

class _DeliveringOrdersTabState extends State<DeliveringOrdersTab> {
  List<Order> orders = [];
  int page = 1;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    context.read<DeliveringOrderBloc>().add(StartOrder());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeliveringOrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderLoaded) {
          setState(() {
            isLoadingMore = false;
            if (page == 1) {
              orders = state.orders;
            } else {
              orders.addAll(state.orders);
            }
          });
        }
      },
      child: Column(
        children: [
          Expanded(
            child: OrderListView(
              orders: orders,
              refreshFunc: () async {
                context.read<DeliveringOrderBloc>().add(StartOrder());

                page = 1;
              },
              loadMoreFunc: () async {
                if (!isLoadingMore) {
                  setState(() {
                    isLoadingMore = true;
                  });
                  page++;
                  context
                      .read<DeliveringOrderBloc>()
                      .add(AddOrder(const [], page));
                }
              },
              loading: isLoadingMore,
            ),
          ),
        ],
      ),
    );
  }
}

class CancelledOrdersTab extends StatefulWidget {
  const CancelledOrdersTab({super.key});

  @override
  State<CancelledOrdersTab> createState() => _CancelledOrdersTabState();
}

class _CancelledOrdersTabState extends State<CancelledOrdersTab> {
  List<Order> orders = [];
  int page = 1;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    context.read<CancelledOrderBloc>().add(StartOrder());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CancelledOrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderLoaded) {
          setState(() {
            isLoadingMore = false;
            if (page == 1) {
              orders = state.orders;
            } else {
              orders.addAll(state.orders);
            }
          });
        }
      },
      child: Column(
        children: [
          Expanded(
            child: OrderListView(
              orders: orders,
              refreshFunc: () async {
                context.read<CancelledOrderBloc>().add(StartOrder());

                page = 1;
              },
              loadMoreFunc: () async {
                if (!isLoadingMore) {
                  setState(() {
                    isLoadingMore = true;
                  });
                  page++;
                  context
                      .read<CancelledOrderBloc>()
                      .add(AddOrder(const [], page));
                }
              },
              loading: isLoadingMore,
            ),
          ),
        ],
      ),
    );
  }
}

class CompletedOrdersTab extends StatefulWidget {
  const CompletedOrdersTab({super.key});

  @override
  State<CompletedOrdersTab> createState() => _CompletedOrdersTabState();
}

class _CompletedOrdersTabState extends State<CompletedOrdersTab> {
  List<Order> orders = [];
  int page = 1;
  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    context.read<CompletedOrderBloc>().add(StartOrder());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CompletedOrderBloc, OrderState>(
      listener: (context, state) {
        if (state is OrderLoaded) {
          setState(() {
            isLoadingMore = false;
            if (page == 1) {
              orders = state.orders;
            } else {
              orders.addAll(state.orders);
            }
          });
        }
      },
      child: Column(
        children: [
          Expanded(
            child: OrderListView(
              orders: orders,
              refreshFunc: () async {
                context.read<CompletedOrderBloc>().add(StartOrder());

                page = 1;
              },
              loadMoreFunc: () async {
                if (!isLoadingMore) {
                  setState(() {
                    isLoadingMore = true;
                  });
                  page++;
                  context
                      .read<CompletedOrderBloc>()
                      .add(AddOrder(const [], page));
                }
              },
              loading: isLoadingMore,
            ),
          ),
        ],
      ),
    );
  }
}

class OrderListView extends StatefulWidget {
  final List<Order> orders;
  final Future<void> Function() refreshFunc;
  final Future<void> Function() loadMoreFunc;
  final bool loading;

  const OrderListView({
    super.key,
    required this.orders,
    required this.refreshFunc,
    required this.loadMoreFunc,
    required this.loading,
  });

  @override
  State<OrderListView> createState() => _OrderListViewState();
}

class _OrderListViewState extends State<OrderListView> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.refreshFunc,
      child: widget.orders.isEmpty
          ? const Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image(
                      image: AssetImage("lib/assets/hoptrong.png"),
                    ),
                    Text(
                      'Chưa có đơn hàng nào',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(height: 250),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: widget.orders.length + 1,
              itemBuilder: (context, index) {
                if (index == widget.orders.length) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: widget.loading
                          ? null
                          : () {
                              widget.loadMoreFunc();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            widget.loading ? Colors.grey : mainColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: widget.loading
                          ? const Text(
                              'Đang tải',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const Text(
                              'Tải thêm',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  );
                } else {
                  final order = widget.orders[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.withOpacity(0.1),
                      child:
                          const Icon(Icons.local_shipping, color: Colors.green),
                    ),
                    title: Text(
                      order.trackingNumber ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    subtitle: _buildOrderDetails(order),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    tileColor: Colors.white,
                    onTap: () {
                      _showOrderDetailsBottomSheet(context, order);
                      context
                          .read<GetImagesBloc>()
                          .add(GetOrderImages(order.id!));
                    },
                  );
                }
              },
            ),
    );
  }

  Widget _buildOrderDetails(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4.0),
        Row(
          children: [
            const Icon(Icons.person, size: 16.0, color: Colors.grey),
            const SizedBox(width: 4.0),
            Text('Người nhận: ${order.nameReceiver ?? ''}'),
          ],
        ),
        const SizedBox(height: 4.0),
        Row(
          children: [
            const Icon(Icons.phone, size: 16.0, color: Colors.grey),
            const SizedBox(width: 4.0),
            Text('SĐT: ${order.phoneNumberReceiver ?? ''}'),
          ],
        ),
        const SizedBox(height: 4.0),
        Row(
          children: [
            const Icon(Icons.location_on, size: 16.0, color: Colors.grey),
            const SizedBox(width: 4.0),
            Expanded(
              child: Text(
                'Địa chỉ: ${order.detailDest ?? ''}, ${order.districtDest ?? ''}, ${order.provinceDest ?? ''}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getLabelText() {
    // switch (selectedFilter) {
    //   case 'name':
    //     return 'Tìm kiếm theo tên người nhận';
    //   case 'location':
    //     return 'Tìm kiếm theo địa điểm người nhận';
    //   case 'phone':
    //     return 'Tìm kiếm theo số điện thoại người nhận';
    //   default:
    //     return 'Tìm kiếm';
    // }
    return "";
  }

  void _showOrderDetailsBottomSheet(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          // Gọi phương thức chia sẻ
                          Share.share("abcde");
                        },
                        icon: const Icon(Icons.share),
                        label: const Text("Chia sẻ"),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 30),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Chi tiết đơn hàng ${order.trackingNumber ?? ''}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const Divider(),
                  _buildOrderDetailTile(
                      'Người gửi', order.nameSender, Icons.person),
                  // _buildOrderDetailTile(
                  //     'Trạng thái', order.statusCode, Icons.person),
                  _buildOrderDetailTile(
                      'SĐT người gửi', order.phoneNumberSender, Icons.phone),
                  _buildOrderDetailTile(
                      'Địa chỉ gửi',
                      '${order.provinceSource ?? ''}, ${order.districtSource ?? ''}, ${order.wardSource ?? ''}, ${order.detailSource ?? ''}',
                      Icons.location_on,
                      sendAddress:
                          '${order.provinceSource ?? ''}, ${order.districtSource ?? ''}, ${order.wardSource ?? ''}, ${order.detailSource ?? ''}',
                      receiveAddress:
                          '${order.provinceDest ?? ''}, ${order.districtDest ?? ''}, ${order.wardDest ?? ''}, ${order.detailDest ?? ''}'),
                  const Divider(),
                  _buildOrderDetailTile(
                      'Người nhận', order.nameReceiver, Icons.person),
                  _buildOrderDetailTile(
                      'SĐT người nhận', order.phoneNumberReceiver, Icons.phone),
                  _buildOrderDetailTile(
                      'Địa chỉ nhận',
                      '${order.provinceDest ?? ''}, ${order.districtDest ?? ''}, ${order.wardDest ?? ''}, ${order.detailDest ?? ''}',
                      Icons.location_on,
                      sendAddress:
                          '${order.provinceSource ?? ''}, ${order.districtSource ?? ''}, ${order.wardSource ?? ''}, ${order.detailSource ?? ''}',
                      receiveAddress:
                          '${order.provinceDest ?? ''}, ${order.districtDest ?? ''}, ${order.wardDest ?? ''}, ${order.detailDest ?? ''}'),
                  const Divider(),
                  _buildOrderDetailTile(
                      'Khối lượng',
                      order.mass != null
                          ? '${order.mass?.toStringAsFixed(2)} kg'
                          : (order.fromMass != null
                              ? "${order.fromMass} - ${order.toMass} kg"
                              : "0 kg"),
                      Icons.line_weight),
                  _buildOrderDetailTile(
                      'Phí',
                      '${order.fee?.toStringAsFixed(0) ?? '0'} VNĐ',
                      Icons.attach_money),

                  _buildOrderDetailTile(
                      'Trạng thái thanh toán',
                      (order.paid!) ? "Đã thanh toán" : "Chưa thanh toán",
                      (Icons.info)),
                  const Divider(), // Thêm dòng phân cách trước khi hiển thị hành trình
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Hành trình đơn hàng',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        (order.statusCode == "PROCESSING" ||
                                order.statusCode == "TAKING")
                            ? Container()
                            : TextButton(
                                child: const Text("Xem"),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TaskRouteWidget(
                                              orderId: order.id!,
                                            )),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),

                  // Hiển thị hành trình đơn hàng
                  if (order.journies != null)
                    _buildJourneyList(order.journies!),
                  _buildImageSignatureSection(order),
                  if (order.statusCode != "RECEIVED")
                    _buildCancelSubmitButton(order),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSignatureSection(Order order) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Hình ảnh và chữ ký',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(height: 8), // Khoảng cách giữa tiêu đề và nội dung
          BlocBuilder<GetImagesBloc, OrderState>(
            builder: (context, state) {
              if (state is GettingImages) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is GotImages) {
                final sendImages = state.sendImages;
                final receiveImages = state.receiveImages;
                final sendSignature = state.sendSignature;
                final receiveSignature = state.receiveSignature;

                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hiển thị hình gửi
                      _buildImageGrid("Hình ảnh gửi", sendImages),

                      const SizedBox(height: 16), // Khoảng cách giữa các phần

                      // Hiển thị hình nhận
                      _buildImageGrid("Hình ảnh nhận", receiveImages),

                      const SizedBox(height: 16), // Khoảng cách giữa các phần

                      // Hiển thị chữ ký
                      _buildSignatureSection("Chữ ký người gửi", sendSignature),
                      const SizedBox(height: 8),
                      _buildSignatureSection(
                          "Chữ ký người nhận", receiveSignature),
                    ],
                  ),
                );
              } else if (state is FailedImage) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Lỗi khi lấy hình: ${state.error}",
                    style: const TextStyle(color: mainColor),
                  ),
                );
              }
              return const Text('Không tìm thấy ảnh hoặc chữ ký.');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(String title, List<Uint8List> images) {
    if (images.isEmpty) {
      return Text('$title: Chưa có hình ảnh');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: images.isNotEmpty ? 100 : 20,
          child: images.isNotEmpty
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImage(
                              image: images[index],
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            images[index],
                            fit: BoxFit.fitWidth,
                            width: 200,
                            height: 200,
                          ),
                        ),
                      ),
                    );
                  },
                )
              : const Text("Chưa có hình ảnh"),
        ),
      ],
    );
  }

  Widget _buildSignatureSection(String title, Uint8List? signature) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        signature != null
            ? GestureDetector(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImage(
                        image: signature,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(
                    signature,
                    height: 100,
                    fit: BoxFit.contain, // Đảm bảo chữ ký không bị cắt
                  ),
                ),
              )
            : const Text("Chưa có chữ ký"),
      ],
    );
  }

  Widget _buildOrderDetailTile(String title, String? value, IconData icon,
      {String sendAddress = "", String receiveAddress = ""}) {
    return icon == Icons.location_on
        ? InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Map2Markers(
                    startAddress: sendAddress,
                    endAddress: receiveAddress,
                  ),
                ),
              );
            },
            child: ListTile(
              leading: Icon(icon, color: Colors.green),
              title: Text(
                "$title (Nhấn để xem)",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(value ?? 'Chưa có thông tin'),
            ))
        : ListTile(
            leading: Icon(icon,
                color:
                    (value == "Chưa thanh toán" ? Colors.red : Colors.green)),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(value ?? 'Chưa có thông tin'),
          );
  }

  Widget _buildJourneyList(List<Journies> journeys) {
    if (journeys.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('Chưa có hành trình nào.'),
      );
    }

    return ListView.builder(
      shrinkWrap: true, // Để ListView nằm gọn trong Modal
      physics:
          const NeverScrollableScrollPhysics(), // Tắt cuộn riêng cho ListView này
      itemCount: journeys.length,
      itemBuilder: (context, index) {
        final journey = journeys[index];
        return _buildJourneyTile(
            journey.message!, DateTime.tryParse(journey.time!));
      },
    );
  }

  Widget _buildJourneyTile(String message, DateTime? timestamp) {
    return ListTile(
      leading: const Icon(Icons.circle, color: Colors.green, size: 15),
      title: Text(message),
      subtitle: Text(
        timestamp != null
            ? '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}'
            : 'Không rõ thời gian',
      ),
    );
  }

  Widget _buildCancelSubmitButton(Order order) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          (order.statusCode == "PROCESSING" || order.statusCode == "TAKING")
              ? ElevatedButton(
                  onPressed: () {
                    _showCancellationDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade200,
                  ),
                  child: const Text(
                    "Từ chối",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                )
              : const ElevatedButton(
                  onPressed: null,
                  child: Text(
                    "Từ chối",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
          const SizedBox(width: 8),
          order.statusCode != "DELIVERING"
              ? const ElevatedButton(
                  onPressed: null,
                  child: Text(
                    "Đã nhận",
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                )
              : ElevatedButton(
                  onPressed: () {
                    _showRatingDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade200,
                  ),
                  child: const Text(
                    "Đã nhận",
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
        ],
      ),
    );
  }

  void _showCancellationDialog(BuildContext context) {
    String? selectedReason;
    TextEditingController otherReasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Lý Do Hủy Đơn Hàng',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text('Không còn nhu cầu'),
                    leading: Radio<String>(
                      value: 'Không còn nhu cầu',
                      groupValue: selectedReason,
                      onChanged: (value) {
                        setState(() {
                          selectedReason = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Sản phẩm không đúng mô tả'),
                    leading: Radio<String>(
                      value: 'Sản phẩm không đúng mô tả',
                      groupValue: selectedReason,
                      onChanged: (value) {
                        setState(() {
                          selectedReason = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Khác'),
                    leading: Radio<String>(
                      value: 'Khác',
                      groupValue: selectedReason,
                      onChanged: (value) {
                        setState(() {
                          selectedReason = value;
                        });
                      },
                    ),
                  ),
                  if (selectedReason == 'Khác')
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextField(
                        controller: otherReasonController,
                        decoration: InputDecoration(
                          hintText: 'Nhập lý do khác',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              child: const Text(
                'Gửi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showRatingDialog(BuildContext context) {
    double rating = 0.0;
    TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đánh Giá Đơn Hàng'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Phần để chọn rating
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.yellow,
                          size: 40,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  // Phần để nhập bình luận
                  TextField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập bình luận của bạn',
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Gửi'),
            ),
          ],
        );
      },
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final Uint8List image;

  FullScreenImage({required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Nền đen để làm nổi bật ảnh
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Thanh app trong suốt
        elevation: 0, // Chưa có bóng đổ
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 40),
          onPressed: () {
            Navigator.of(context).pop(); // Đóng màn hình khi nhấn nút X
          },
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.memory(image), // Hiển thị ảnh toàn màn hình
        ),
      ),
    );
  }
}
