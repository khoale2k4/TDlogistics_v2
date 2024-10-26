import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlogistic_v2/core/models/order_model.dart';
import 'package:tdlogistic_v2/shipper/bloc/task_bloc.dart';
import 'package:tdlogistic_v2/shipper/bloc/task_event.dart';
import 'package:tdlogistic_v2/shipper/bloc/task_state.dart';
import 'package:tdlogistic_v2/shipper/data/models/task.dart';
import 'package:tdlogistic_v2/core/constant.dart';

class ShipperHistory extends StatefulWidget {
  const ShipperHistory({super.key});

  @override
  State<ShipperHistory> createState() => _ShipperHistoryState();
}

class _ShipperHistoryState extends State<ShipperHistory> {
  String _selectedFilter = 'name'; // Loại lọc mặc định là theo tên
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskBlocSearchShip>().add(const GetTasks());
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _searchController.dispose();
    super.dispose();
  }

  String _getLabelText() {
    switch (_selectedFilter) {
      case 'name':
        return 'Tìm kiếm theo tên';
      case 'location':
        return 'Tìm kiếm theo địa điểm';
      case 'phone':
        return 'Tìm kiếm theo số điện thoại';
      default:
        return 'Tìm kiếm';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Lịch sử",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          elevation: 2, // Adds slight shadow for visual separation
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: mainColor,
        ),
        backgroundColor: Colors.white,
        body: _buildOrderList(context));
  }

  Widget _buildOrderList(BuildContext context) {
    return BlocBuilder<TaskBlocSearchShip, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TaskLoaded && state.totalTasks > 0) {
          return Column(children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // DropdownButton để chọn loại lọc
                  DropdownButton<String>(
                    value: _selectedFilter,
                    items: const [
                      DropdownMenuItem(
                          value: 'name', child: Text('Lọc theo tên')),
                      DropdownMenuItem(
                          value: 'location', child: Text('Lọc theo địa điểm')),
                      DropdownMenuItem(
                          value: 'phone',
                          child: Text('Lọc theo số điện thoại')),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFilter = newValue!;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // TextField để nhập thông tin tìm kiếm
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText:
                          _getLabelText(), // Thay đổi label text dựa trên loại lọc đã chọn
                      prefixIcon:
                          const Icon(Icons.search), // Thêm icon tìm kiếm
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onChanged: (value) {
                      // Thực hiện logic tìm kiếm tại đây
                      print('Tìm kiếm theo $_selectedFilter: $value');
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: TaskListView(tasks: state.tasks, searchController: _searchController,),
            ),
            ElevatedButton(
              onPressed: () {
                // final newOrder = Order(/* thông tin đơn hàng mới */);
                context.read<TaskBlocSearchShip>().add(AddTask());
              },
              child: const Text('Tải thêm'),
            ),
            const SizedBox(height: 20),
          ]);
        } else if (state is TaskError) {
          return Center(child: Text('Lỗi: ${state.error}'));
        }
        return const Center(
          child: Column(
            children: [
              Image(
                image: AssetImage("lib/assets/done.png"),
                height: 350,
              ),
              Text(
                'Bạn đã hoàn thành tất cả!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              )
            ],
          ),
        );
      },
    );
  }
}

class TaskListView extends StatefulWidget {
  final List<Task> tasks;
  final bool isSender;
  final TextEditingController searchController;

  const TaskListView({super.key, required this.tasks, this.isSender = true, required this.searchController});

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  final TextEditingController searchController = TextEditingController();
  String selectedFilter = "name";
  List<Task> filteredOrders = [];

  @override
  void initState() {
    super.initState();
    // Lắng nghe khi có sự thay đổi trong textfield
    searchController.addListener(_filterOrders);
    filteredOrders = widget.tasks;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterOrders() {
    setState(() {
      filteredOrders = widget.tasks.where((task) {
        final searchTerm = searchController.text.toLowerCase();

        if (selectedFilter == 'name') {
          return (task.order!.nameReceiver ?? '')
              .toLowerCase()
              .contains(searchTerm);
        } else if (selectedFilter == 'location') {
          final location =
              '${task.order!.detailDest ?? ''}, ${task.order!.districtDest ?? ''}, ${task.order!.provinceDest ?? ''}';
          return location.toLowerCase().contains(searchTerm);
        } else if (selectedFilter == 'phone') {
          return (task.order!.phoneNumberReceiver ?? '').contains(searchTerm);
        }
        return false;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.tasks.length,
      itemBuilder: (context, index) {
        final task = filteredOrders[index];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          leading: CircleAvatar(
            backgroundColor: Colors.green.withOpacity(0.1),
            child: const Icon(Icons.local_shipping, color: Colors.green),
          ),
          title: Text(
            task.order?.trackingNumber ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.0,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4.0),
              Row(
                children: [
                  const Icon(Icons.person, size: 16.0, color: Colors.grey),
                  const SizedBox(width: 4.0),
                  widget.isSender
                      ? Text(
                          'Người gửi: ${task.order?.nameSender ?? ''}',
                          style: const TextStyle(fontSize: 14.0),
                        )
                      : Text(
                          'Người nhận: ${task.order?.nameReceiver ?? ''}',
                          style: const TextStyle(fontSize: 14.0),
                        ),
                ],
              ),
              const SizedBox(height: 4.0),
              Row(
                children: [
                  const Icon(Icons.phone, size: 16.0, color: Colors.grey),
                  const SizedBox(width: 4.0),
                  Text(
                    'SĐT: ${widget.isSender ? task.order?.phoneNumberSender : task.order?.phoneNumberReceiver ?? ''}',
                    style: const TextStyle(fontSize: 14.0),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16.0, color: Colors.grey),
                  const SizedBox(width: 4.0),
                  Expanded(
                    child: widget.isSender
                        ? Text(
                            'Địa chỉ: ${task.order?.detailSource ?? ''}, ${task.order?.districtSource ?? ''}, ${task.order?.provinceSource ?? ''}',
                            style: const TextStyle(fontSize: 14.0),
                            overflow: TextOverflow.ellipsis,
                          )
                        : Text(
                            'Địa chỉ: ${task.order?.detailDest ?? ''}, ${task.order?.districtDest ?? ''}, ${task.order?.provinceDest ?? ''}',
                            style: const TextStyle(fontSize: 14.0),
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                ],
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          tileColor: Colors.white,
          onTap: () {
            context
                .read<GetImagesShipBloc>()
                .add(GetOrderImages(task.order!.id!));
            _showOrderDetailsBottomSheet(context, task);
          },
        );
      },
    );
  }

  void _showOrderDetailsBottomSheet(BuildContext context, Task task) {
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
                      'Chi tiết đơn hàng ${task.order?.trackingNumber ?? ''}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const Divider(),
                  _buildOrderDetailTile(
                      'Người gửi', task.order?.nameSender, Icons.person),
                  _buildOrderDetailTile('SĐT người gửi',
                      task.order?.phoneNumberSender, Icons.phone),
                  _buildOrderDetailTile(
                      'Người nhận', task.order?.nameReceiver, Icons.person),
                  _buildOrderDetailTile('SĐT người nhận',
                      task.order?.phoneNumberReceiver, Icons.phone),
                  _buildOrderDetailTile(
                      'Địa chỉ gửi',
                      '${task.order?.provinceSource ?? ''}, ${task.order?.districtSource ?? ''}, ${task.order?.wardSource ?? ''}, ${task.order?.detailSource ?? ''}',
                      Icons.location_on),
                  _buildOrderDetailTile(
                      'Địa chỉ nhận',
                      '${task.order?.provinceDest ?? ''}, ${task.order?.districtDest ?? ''}, ${task.order?.wardDest ?? ''}, ${task.order?.detailDest ?? ''}',
                      Icons.location_on),
                  _buildOrderDetailTile(
                      'Khối lượng',
                      '${task.order?.mass?.toStringAsFixed(2) ?? ''} kg',
                      Icons.line_weight),
                  _buildOrderDetailTile(
                      'Phí',
                      '${task.order?.fee?.toStringAsFixed(2) ?? ''} VNĐ',
                      Icons.attach_money),
                  _buildOrderDetailTile('Trạng thái đơn hàng',
                      task.order?.statusCode, Icons.info),

                  const Divider(), // Thêm dòng phân cách trước khi hiển thị hành trình
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Hành trình đơn hàng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),

                  // Hiển thị hành trình đơn hàng
                  if (task.order?.journies != null)
                    _buildJourneyList(task.order!.journies!),
                  _buildImageSignatureSection(task.order!)
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
          BlocBuilder<GetImagesShipBloc, TaskState>(
            builder: (context, state) {
              if (state is GettingImages) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is GotImages) {
                List<Uint8List> sendImages = state.sendImages;
                List<Uint8List> receiveImages = state.receiveImages;
                Uint8List? sendSignature = state.sendSignature;
                Uint8List? receiveSignature = state.receiveSignature;

                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hiển thị hình gửi với nút thêm ảnh
                      _buildImageGridWithAddButton(context, "Hình ảnh gửi",
                          sendImages, "SEND", order.id!),

                      const SizedBox(height: 16), // Khoảng cách giữa các phần

                      // Hiển thị hình nhận với nút thêm ảnh
                      _buildImageGridWithAddButton(context, "Hình ảnh nhận",
                          receiveImages, "RECEIVE", order.id!),

                      const SizedBox(height: 16), // Khoảng cách giữa các phần

                      // Hiển thị chữ ký (không có nút thêm)
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

// Widget hiển thị grid hình ảnh và thêm nút thêm ảnh
  Widget _buildImageGridWithAddButton(BuildContext context, String title,
      List<Uint8List> images, String category, String orderId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true, // Đảm bảo GridView không chiếm toàn bộ không gian
          physics:
              const NeverScrollableScrollPhysics(), // Tắt cuộn riêng của GridView
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1, // Số cột
            crossAxisSpacing: 8, // Khoảng cách giữa các cột
            mainAxisSpacing: 8, // Khoảng cách giữa các hàng
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Khi nhấn vào ảnh, mở một màn hình mới để phóng to ảnh
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenImage(image: images[index]),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10), // Bo góc ảnh
                child: Image.memory(
                  images[index],
                  fit: BoxFit.scaleDown,
                ),
              ),
            );
          },
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
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  signature,
                  height: 100,
                  fit: BoxFit.contain, // Đảm bảo chữ ký không bị cắt
                ),
              )
            : const Text("Chưa có chữ ký"),
      ],
    );
  }

  Widget _buildOrderDetailTile(String title, String? value, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
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
