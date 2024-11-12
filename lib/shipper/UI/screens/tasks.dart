import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:tdlogistic_v2/core/models/order_model.dart';
import 'package:tdlogistic_v2/shipper/UI/screens/map2markers.dart';
import 'package:tdlogistic_v2/shipper/UI/screens/signature_screen.dart';
import 'package:tdlogistic_v2/shipper/bloc/task_bloc.dart';
import 'package:tdlogistic_v2/shipper/bloc/task_event.dart';
import 'package:tdlogistic_v2/shipper/bloc/task_state.dart';
import 'package:tdlogistic_v2/shipper/data/models/task.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/shipper/data/repositories/task_repository.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TasksWidget extends StatefulWidget {
  final String token;
  const TasksWidget({super.key, required this.token});

  @override
  State<TasksWidget> createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TasksWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? qrController;

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
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
        //     onPressed: _showQRScanner,
        //   ),
        // ],
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
              child: TaskListView(
                tasks: state.tasks,
                token: widget.token,
              ),
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

  Widget _buildOrderSendList(BuildContext context) {
    return BlocBuilder<TaskBlocShipSend, TaskState>(
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TaskLoaded && state.totalTasks > 0) {
          return Column(children: [
            Expanded(
              child: TaskListView(
                tasks: state.tasks,
                token: widget.token,
                isSender: false,
              ),
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
  final String token;

  const TaskListView(
      {super.key,
      required this.tasks,
      this.isSender = true,
      required this.token});

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
              color: Colors.white,
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

                  // Hiển thị thông tin người gửi/nhận dựa trên vai trò
                  if (isSender) ...[
                    _buildOrderDetailTile(
                        'Người gửi', task.order?.nameSender, Icons.person),
                    _buildOrderDetailTile('SĐT người gửi',
                        task.order?.phoneNumberSender, Icons.phone),
                    _buildOrderDetailTile(
                      'Địa chỉ gửi',
                      '${task.order?.provinceSource ?? ''}, ${task.order?.districtSource ?? ''}, ${task.order?.wardSource ?? ''}, ${task.order?.detailSource ?? ''}',
                      Icons.location_on,
                      address:
                          "${task.order!.detailSource} ${task.order!.districtSource} ${task.order!.wardSource} ${task.order!.provinceSource}",
                    ),
                  ] else ...[
                    _buildOrderDetailTile(
                        'Người nhận', task.order?.nameReceiver, Icons.person),
                    _buildOrderDetailTile('SĐT người nhận',
                        task.order?.phoneNumberReceiver, Icons.phone),
                    _buildOrderDetailTile(
                      'Địa chỉ nhận',
                      '${task.order?.provinceDest ?? ''}, ${task.order?.districtDest ?? ''}, ${task.order?.wardDest ?? ''}, ${task.order?.detailDest ?? ''}',
                      Icons.location_on,
                      address:
                          "${task.order!.detailDest} ${task.order!.districtDest} ${task.order!.wardDest} ${task.order!.provinceDest}",
                    ),
                  ],

                  _buildOrderDetailTile(
                      'Khối lượng',
                      '${task.order?.mass?.toStringAsFixed(2) ?? ''} kg',
                      Icons.line_weight),
                  _buildOrderDetailTile(
                      'Phí',
                      '${task.order?.fee?.toStringAsFixed(2) ?? ''} VNĐ',
                      Icons.attach_money,
                      qrData: (!task.order!.paid! &&
                              (isSender != task.order!.receiverWillPay))
                          ? task.order?.qrcode
                          : ""),
                  _buildOrderDetailTile('Trạng thái thanh toán',
                      (task.order!.paid!)?"Đã thanh toán":"Chưa thanh toán", (Icons.info)),
                  const Divider(),

                  // Hành trình đơn hàng
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
                  _buildJourneyList(task.order!.journies!),
                  const Divider(),
                  _buildImageSignatureSection(task.order!, isSender),
                  _buildCancelSubmitButton(isSender, task.id!),
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
                List<String> sendIds = state.sendIds;
                List<Uint8List> receiveImages = state.receiveImages;
                List<String> receiveIds = state.receiveIds;
                Uint8List? sendSignature = state.sendSignature;
                String sendSignId = state.sendSignId;
                Uint8List? receiveSignature = state.receiveSignature;
                String receiveSignId = state.receiveSignId;

                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hiển thị hình gửi với nút thêm ảnh
                      if (isSender) ...[
                        _buildImageGridWithAddButton(context, "Hình ảnh gửi",
                            sendImages, "SEND", order.id!, sendIds),

                        const SizedBox(height: 16), // Khoảng cách giữa các phần
                        // Hiển thị chữ ký (không có nút thêm)
                        _buildSignatureSection("Chữ ký người gửi",
                            sendSignature, order.id!, "SEND", sendSignId),
                      ] else ...[
                        // Hiển thị hình nhận với nút thêm ảnh
                        _buildImageGridWithAddButton(context, "Hình ảnh nhận",
                            receiveImages, "RECEIVE", order.id!, receiveIds),

                        const SizedBox(height: 16), // Khoảng cách giữa các phần
                        const SizedBox(height: 8),
                        _buildSignatureSection(
                            "Chữ ký người nhận",
                            receiveSignature,
                            order.id!,
                            "RECEIVE",
                            receiveSignId),
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

  Widget _buildImageGridWithAddButton(
      BuildContext context,
      String title,
      List<Uint8List> images,
      String category,
      String orderId,
      List<String> ids) {
    return BlocListener<UpdateImagesShipBloc, TaskState>(
      listener: (context, state) {
        if (state is FailedImage) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Thất bại'),
                content: Text('Không thể thêm ảnh: ${state.error}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Thử lại'),
                  ),
                ],
              );
            },
          );
        }
      },
      child: Column(
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
                          bool? shouldDelete = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImage(
                                image: images[index],
                              ),
                            ),
                          );

                          if (shouldDelete == true) {
                            //
                            context
                                .read<UpdateImagesShipBloc>()
                                .add(DeleteImage(ids[index]));
                            await Future.delayed(const Duration(seconds: 1));
                            context
                                .read<GetImagesShipBloc>()
                                .add(GetOrderImages(orderId));
                            (context as Element).markNeedsBuild();
                          }
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
          const SizedBox(height: 8),
          images.length < 9
              ? ElevatedButton.icon(
                  onPressed: () {
                    _onAddImagePressed(context, images, category, orderId);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm ảnh'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  void _onUpdateImages(BuildContext context, List<Uint8List> images,
      Uint8List? newImage, String category, String orderId,
      {bool isSign = false}) async {
    try {
      context.read<UpdateImagesShipBloc>().add(
            AddImageEvent(
                curImages: [],
                orderId: orderId,
                category: category,
                newImage: newImage,
                isSign: isSign),
          );

      await Future.delayed(const Duration(seconds: 1));
      context.read<GetImagesShipBloc>().add(GetOrderImages(orderId));
    } catch (error) {
      print("Error updating images: $error");
    }
  }

  void _onAddImagePressed(BuildContext context, List<Uint8List> images,
      String category, String orderId) async {
    final ImagePicker picker = ImagePicker();

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
                  Navigator.pop(context, file);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Chụp từ camera'),
                onTap: () async {
                  final XFile? file =
                      await picker.pickImage(source: ImageSource.camera);
                  Navigator.pop(context, file);
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
        if (!mounted) return;

        List<Uint8List> editableImages = List.from(images);
        _onUpdateImages(context, editableImages, imageBytes, category, orderId);
      } catch (error) {
        print("Error uploading image: ${error.toString()}");
      }
    }
  }

  Widget _buildSignatureSection(String title, Uint8List? signature,
      String orderId, String category, String signatureId) {
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
                  bool? shouldDelete = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImage(
                        image: signature,
                      ),
                    ),
                  );

                  if (shouldDelete == true) {
                    context.read<UpdateImagesShipBloc>().add(AddImageEvent(
                        category: category,
                        curImages: [],
                        newImage: null,
                        orderId: orderId,
                        isSign: true));
                    await Future.delayed(const Duration(seconds: 1));
                    context
                        .read<GetImagesShipBloc>()
                        .add(GetOrderImages(orderId));
                    (context as Element).markNeedsBuild();
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      signature,
                      fit: BoxFit.fitWidth,
                      width: 200,
                      height: 200,
                    ),
                  ),
                ),
              )
            : const Text("Chưa có chữ ký"),
        signature == null
            ? ElevatedButton.icon(
                onPressed: () {
                  _onAddSignaturePressed(context, signature, orderId, category);
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

  void _onAddSignaturePressed(BuildContext context, Uint8List? signature,
      String orderId, String category) async {
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
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Ký tên'),
                onTap: () async {
                  // Mở trang ký tên và trả về kết quả sau khi ký
                  final XFile? signatureData = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SignatureScreen()),
                  );
                  Navigator.pop(context, signatureData);
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
        signature = imageBytes;
        _onUpdateImages(context, [], imageBytes, category, orderId,
            isSign: true);
      } catch (error) {
        print("Error uploading image: ${error.toString()}");
      }
    }
  }

  Widget _buildOrderDetailTile(String title, String? value, IconData icon,
      {String address = "", String qrData = ""}) {
    void _showQrDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Thanh toán"),
            content: Container(
              // Wrap QrImage in a Container
              width: 200,
              height: 200,
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200.0,
                errorStateBuilder: (context, error) {
                  return const Center(child: Text("Không thể tạo mã QR"));
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Đóng"),
              ),
            ],
          );
        },
      );
    }

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
        : qrData != ""
            ? InkWell(
                onTap: () {
                  _showQrDialog();
                },
                child: ListTile(
                  leading: Icon(icon, color: Colors.green),
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  trailing: const Icon(Icons.qr_code),
                  subtitle: Text(value ?? 'Chưa có thông tin'),
                ))
            : icon == Icons.location_on
                ? InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Map2Markers(
                            endAddress: address,
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
                    leading: Icon(icon, color: (value == "Chưa thanh toán"?Colors.red:Colors.green)),
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

  Widget _buildCancelSubmitButton(bool isSender, String taskId) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () {
              _showCancellationDialog(context, taskId);
            },
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
                  onPressed: () async {
                    TaskRepository taskRepository = TaskRepository();
                    taskRepository.confirmTakenTasks(widget.token, taskId);
                    await Future.delayed(const Duration(seconds: 1));
                    taskRepository.confirmDeliverTasks(widget.token, taskId);

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context.read<TaskBlocShipReceive>().add(StartTask());
                      context.read<TaskBlocShipSend>().add(StartTask());
                    });
                    Navigator.pop(context);
                  },
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
                  onPressed: () {
                    TaskRepository taskRepository = TaskRepository();
                    taskRepository.confirmReceivedTasks(widget.token, taskId);

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context.read<TaskBlocShipReceive>().add(StartTask());
                      context.read<TaskBlocShipSend>().add(StartTask());
                    });
                    Navigator.pop(context);
                  },
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

  void _showCancellationDialog(BuildContext context, String taskId) {
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
                    title: const Text('Không thể liên lạc với khách hàng'),
                    leading: Radio<String>(
                      value: 'Không thể liên lạc với khách hàng',
                      groupValue: selectedReason,
                      onChanged: (value) {
                        setState(() {
                          selectedReason = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Khách hàng từ chối đưa/nhận hàng'),
                    leading: Radio<String>(
                      value: 'Khách hàng từ chối đưa/nhận hàng',
                      groupValue: selectedReason,
                      onChanged: (value) {
                        setState(() {
                          selectedReason = value;
                        });
                      },
                    ),
                  ),
                  // ListTile(
                  //   title: const Text('Khác'),
                  //   leading: Radio<String>(
                  //     value: 'Khác',
                  //     groupValue: selectedReason,
                  //     onChanged: (value) {
                  //       setState(() {
                  //         selectedReason = value;
                  //       });
                  //     },
                  //   ),
                  // ),
                  // if (selectedReason == 'Khác')
                  //   Padding(
                  //     padding: const EdgeInsets.only(top: 8.0),
                  //     child: TextField(
                  //       controller: otherReasonController,
                  //       decoration: InputDecoration(
                  //         hintText: 'Nhập lý do khác',
                  //         border: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(10),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                print('Selected Reason: ${selectedReason ?? "Không có"}');
                print('Other Reason: ${otherReasonController.text}');
                TaskRepository taskRepository = TaskRepository();
                taskRepository.cancelTasks(widget.token, taskId, "TIMEOUT");
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
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey,
              ),
              child: const Text('Hủy'),
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 40),
          onPressed: () {
            Navigator.of(context).pop(false); // Đóng màn hình mà không xoá
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 30),
            onPressed: () async {
              // Hiển thị hộp thoại xác nhận xoá
              bool confirmDelete = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Xác nhận xoá"),
                      content: const Text(
                          "Bạn có chắc chắn muốn xoá ảnh này không?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text("Huỷ"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text("Xoá"),
                        ),
                      ],
                    ),
                  ) ??
                  false;

              if (confirmDelete) {
                Navigator.of(context).pop(true); // Trả về true để xoá ảnh
              }
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.memory(image),
        ),
      ),
    );
  }
}
