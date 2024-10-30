import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tdlogistic_v2/core/models/order_model.dart';
import 'package:tdlogistic_v2/shipper/bloc/task_bloc.dart';
import 'package:tdlogistic_v2/shipper/bloc/task_event.dart';
import 'package:tdlogistic_v2/shipper/bloc/task_state.dart';
import 'package:tdlogistic_v2/shipper/data/models/task.dart';
import 'package:tdlogistic_v2/core/constant.dart';

class TasksWidget extends StatefulWidget {
  const TasksWidget({super.key});

  @override
  State<TasksWidget> createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TasksWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;

  String _selectedFilter = 'name'; // Loại lọc mặc định là theo tên
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskBlocShipReceive>().add(StartTask());
      context.read<TaskBlocShipSend>().add(StartTask());
    });
  }

  @override
  void dispose() {
    qrController?.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _confirmOrder(Order order) {
    print("Order ${order.trackingNumber} đã được xác nhận.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nhiệm vụ",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: mainColor,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          unselectedLabelStyle: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.normal, color: Colors.black),
          tabs: [
            Tab(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: _tabController.index == 0
                    ? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                    : const TextStyle(fontSize: 14),
                child: const Text("Nhận hàng"),
              ),
            ),
            Tab(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: _tabController.index == 1
                    ? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                    : const TextStyle(fontSize: 14),
                child: const Text("Gửi hàng"),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: _showQRScanner,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderReceiveList(context),
          _buildOrderSendList(context),
        ],
      ),
    );
  }

  Widget _buildOrderReceiveList(BuildContext context) {
    return BlocBuilder<TaskBlocShipReceive, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TaskLoaded && state.totalTasks > 0) {
          return Column(children: [
            Expanded(
              child: TaskListView(tasks: state.tasks),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<TaskBlocShipReceive>().add(AddTask());
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

  Widget _buildOrderSendList(BuildContext context) {
    return BlocBuilder<TaskBlocShipSend, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TaskLoaded && state.totalTasks > 0) {
          return Column(children: [
            Expanded(
              child: TaskListView(tasks: state.tasks),
            ),
            ElevatedButton(
              onPressed: () {
                // final newOrder = Order(/* thông tin đơn hàng mới */);
                context.read<TaskBlocShipSend>().add(AddTask());
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

  void _showQRScanner() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Quét mã QR"),
          content: SizedBox(
            width: 300,
            height: 300,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                qrController?.pauseCamera();
                Navigator.of(context).pop();
              },
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    qrController = controller;
    controller.scannedDataStream.listen((scanData) {
      // Xử lý dữ liệu sau khi quét QR
      print(scanData.code);
    });
  }
}

class TaskListView extends StatefulWidget {
  final List<Task> tasks;
  final bool isSender;

  const TaskListView({super.key, required this.tasks, this.isSender = true});

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.tasks.length,
      itemBuilder: (context, index) {
        final task = widget.tasks[index];
        // sửa cái này
        bool agent = true;
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          leading: agent
              ? CircleAvatar(
                  backgroundColor: Colors.red.withOpacity(0.1),
                  child: const Icon(Icons.local_fire_department,
                      color: Colors.red),
                )
              : CircleAvatar(
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
              const SizedBox(height: 4.0),
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
            _showOrderDetailsBottomSheet(context, task, widget.isSender);
          },
        );
      },
    );
  }

  void _showOrderDetailsBottomSheet(
      BuildContext context, Task task, bool isSender) {
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
                  if (widget.isSender) ...[
                    _buildOrderDetailTile(
                        'Người gửi', task.order?.nameSender, Icons.person),
                    _buildOrderDetailTile('SĐT người gửi',
                        task.order?.phoneNumberSender, Icons.phone),
                    _buildOrderDetailTile(
                        'Địa chỉ gửi',
                        '${task.order?.provinceSource ?? ''}, ${task.order?.districtSource ?? ''}, ${task.order?.wardSource ?? ''}, ${task.order?.detailSource ?? ''}',
                        Icons.location_on),
                  ] else ...[
                    _buildOrderDetailTile(
                        'Người nhận', task.order?.nameReceiver, Icons.person),
                    _buildOrderDetailTile('SĐT người nhận',
                        task.order?.phoneNumberReceiver, Icons.phone),
                    _buildOrderDetailTile(
                        'Địa chỉ nhận',
                        '${task.order?.provinceDest ?? ''}, ${task.order?.districtDest ?? ''}, ${task.order?.wardDest ?? ''}, ${task.order?.detailDest ?? ''}',
                        Icons.location_on),
                  ],
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
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.map,
                            size: 30,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _buildJourneyList(task.order!.journies!),
                  _buildImageSignatureSection(task.order!, isSender),
                  _buildCancelSubmitButton(isSender),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSignatureSection(Order order, bool isSender) {
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
                      if (isSender) ...[
                        _buildImageGridWithAddButton(context, "Hình ảnh gửi",
                            sendImages, "SEND", order.id!),

                        const SizedBox(height: 16), // Khoảng cách giữa các phần
                        // Hiển thị chữ ký (không có nút thêm)
                        _buildSignatureSection(
                            "Chữ ký người gửi", sendSignature),
                      ] else ...[
                        // Hiển thị hình nhận với nút thêm ảnh
                        _buildImageGridWithAddButton(context, "Hình ảnh nhận",
                            receiveImages, "RECEIVE", order.id!),

                        const SizedBox(height: 16), // Khoảng cách giữa các phần
                        const SizedBox(height: 8),
                        _buildSignatureSection(
                            "Chữ ký người nhận", receiveSignature),
                      ]
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
        SizedBox(
          height: images.isNotEmpty ? 100 : 20, // Chiều cao của ListView ngang
          child: images.isNotEmpty
              ? ListView.builder(
                  scrollDirection: Axis.horizontal, // Cuộn theo chiều ngang
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Khi nhấn vào ảnh, mở một màn hình mới để phóng to ảnh
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FullScreenImage(image: images[index]),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right: 8), // Khoảng cách giữa các ảnh
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10), // Bo góc ảnh
                          child: Image.memory(
                            images[index],
                            fit: BoxFit.fitWidth,
                            width: 200, // Chiều rộng của mỗi ảnh
                            height: 200, // Chiều cao của mỗi ảnh
                          ),
                        ),
                      ),
                    );
                  },
                )
              : const Text("Chưa có hình ảnh"),
        ),
        const SizedBox(height: 8),
        // Nút thêm ảnh
        images.length < 9
            ? ElevatedButton.icon(
                onPressed: () {
                  _onAddImagePressed(context, images, category,
                      orderId); // Gọi sự kiện thêm ảnh
                },
                icon: const Icon(Icons.add),
                label: const Text('Thêm ảnh'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              )
            : Container(),
      ],
    );
  }

// Hàm xử lý sự kiện khi nhấn nút thêm ảnh
  void _onAddImagePressed(BuildContext context, List<Uint8List> images,
      String category, String orderId) async {
    final ImagePicker picker = ImagePicker();

    // Hiển thị tùy chọn chọn ảnh từ thư viện hoặc camera
    final XFile? pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Chọn từ thư viện'),
                onTap: () async {
                  final XFile? file =
                      await picker.pickImage(source: ImageSource.gallery);
                  Navigator.pop(context, file); // Trả về file sau khi chọn
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Chụp từ camera'),
                onTap: () async {
                  final XFile? file =
                      await picker.pickImage(source: ImageSource.camera);
                  Navigator.pop(context, file); // Trả về file sau khi chụp
                },
              ),
            ],
          ),
        );
      },
    );

    if (pickedFile != null) {
      try {
        Uint8List imageBytes = await pickedFile.readAsBytes();
        List<Uint8List> editableImages = List.from(images);
        editableImages.add(imageBytes);

        context.read<UpdateImagesShipBloc>().add(
              AddImageEvent(
                  curImages: images,
                  orderId: orderId,
                  category: category,
                  newImage: imageBytes),
            );
        await Future.delayed(const Duration(seconds: 1));
        context.read<GetImagesShipBloc>().add(GetOrderImages(orderId));
      } catch (error) {
        print("Error uploading image: ${error.toString()}");
      }
    }
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
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Thêm ảnh'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
        )
      ],
    );
  }

  Widget _buildOrderDetailTile(String title, String? value, IconData icon) {
    return icon == Icons.phone
        ? InkWell(
            onTap: () {},
            child: ListTile(
              leading: Icon(icon, color: Colors.green),
              title: Text(
                "$title (Nhấn để gọi)",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(value ?? 'Chưa có thông tin'),
            ))
        : ListTile(
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

  Widget _buildCancelSubmitButton(bool isSender) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade200,
            ),
            child: const Text(
              "Từ chối",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          isSender
              ? ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade100,
                  ),
                  child: const Text(
                    "Xác nhận nhận hàng",
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                )
              : ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade100,
                  ),
                  child: const Text(
                    "Xác nhận gửi hàng",
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
        ],
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
