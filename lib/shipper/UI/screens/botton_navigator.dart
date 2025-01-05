import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlogistic_v2/auth/data/models/user_model.dart';
import 'package:tdlogistic_v2/shipper/UI/screens/contact/chats_screen.dart';
import 'package:tdlogistic_v2/shipper/UI/screens/map_widget.dart';
import 'package:tdlogistic_v2/shipper/UI/screens/tasks.dart';
import 'package:tdlogistic_v2/shipper/UI/screens/shipper_info.dart';
import 'package:tdlogistic_v2/shipper/UI/screens/history.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/shipper/bloc/task_bloc.dart';
import 'package:tdlogistic_v2/shipper/bloc/task_event.dart';
import 'package:tdlogistic_v2/shipper/bloc/task_state.dart';
import 'package:tdlogistic_v2/shipper/data/models/task.dart';

class ShipperNavigatePage extends StatefulWidget {
  final User user;
  final List<Task> tasks;
  final Function(String, String) sendMessage;

  const ShipperNavigatePage(
      {super.key,
      required this.user,
      required this.tasks,
      required this.sendMessage});

  @override
  _ShipperNavigatePageState createState() => _ShipperNavigatePageState();
}

class _ShipperNavigatePageState extends State<ShipperNavigatePage> {
  int _currentIndex = 0;
  List<Task> currTasks = [];
  int page = 1;
  bool isLoadingMore = false;
  late User user;

  // Các trang scaffold khác nhau
  List<Widget> _pages = [];
  List<String> ordersDelevering = [];

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _pages = [
      const TasksWidget(),
      const ShipperHistory(),
      const MapWidget(),
      ChatListScreen(sendMessage: widget.sendMessage),
      ShipperInfor(user: user),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PendingOrderBloc>().add(GetPendingTask());
    });
  }

  // Hàm cập nhật trang khi chọn tab khác
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex, // Hiển thị trang dựa trên chỉ số hiện tại
        children: _pages, // Lưu trạng thái các trang
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex, // Vị trí hiện tại
        onTap: onTabTapped, // Gọi hàm khi tab được nhấn
        items: [
          BottomNavigationBarItem(
            icon: _buildIconWithCircle(Icons.home, 0),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: _buildIconWithCircle(Icons.history, 1),
            label: 'Lịch sử',
          ),
          BottomNavigationBarItem(
            icon: _buildIconWithCircle(Icons.map, 2),
            label: 'Bản đồ',
          ),
          BottomNavigationBarItem(
            icon: _buildIconWithCircle(Icons.message, 3),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: _buildIconWithCircle(Icons.person, 4),
            label: 'Bạn',
          ),
        ],
        type: BottomNavigationBarType.fixed, // Đảm bảo các tab không bị cuộn
      ),
      floatingActionButton: BlocListener<PendingOrderBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskLoaded) {
            setState(() {
              isLoadingMore = false;
              if (page == 1) {
                currTasks = state.tasks;
              } else {
                currTasks.addAll(state.tasks);
              }
            });
          }
        },
        child: _currentIndex < 2
            ? Stack(
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      buildBottomSheet(context);
                    },
                    backgroundColor: Colors.white60,
                    child: const Icon(Icons.notifications_active_outlined),
                  ),
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Center(
                        child: BlocBuilder<PendingOrderBloc, TaskState>(
                          builder: (context, state) {
                            if (state is TaskLoaded) {
                              return Text(
                                state.totalTasks.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }
                            return const Text(
                              "0",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : Container(),
      ),
    );
  }

  Widget _buildIconWithCircle(IconData icon, int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // Thời gian chuyển đổi
      decoration: _currentIndex == index
          ? BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.shade100, // Màu nền cho tab được chọn
            )
          : null,
      padding: const EdgeInsets.all(8), // Khoảng cách xung quanh icon
      child: Icon(
        icon,
        size: _currentIndex == index
            ? 35
            : 24, // Kích thước lớn hơn cho icon được chọn
        color: _currentIndex == index
            ? mainColor
            : Colors.grey, // Màu icon khi được chọn
      ),
    );
  }

  void buildBottomSheet(context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép bottom sheet full screen
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return TasksNotifications(
          tasks: currTasks,
          reload: () async {
            context.read<PendingOrderBloc>().add(GetPendingTask());
            page = 1;
          },
          onLoadMore: () async {
            if (!isLoadingMore) {
              setState(() {
                isLoadingMore = true;
              });
              page++;
              context.read<PendingOrderBloc>().add(AddTask(page));
            }
          },
          isLoading: isLoadingMore,
        );
      },
    );
  }
}

class TasksNotifications extends StatefulWidget {
  final List<Task> tasks;
  final Future<void> Function() reload;
  final Future<void> Function() onLoadMore;
  final bool isLoading;
  const TasksNotifications(
      {super.key,
      required this.tasks,
      required this.reload,
      required this.onLoadMore,
      required this.isLoading});

  @override
  State<TasksNotifications> createState() => _TasksNotificationsState();
}

class _TasksNotificationsState extends State<TasksNotifications> {
  void confirmTask(BuildContext context, String taskId) {
    context.read<PendingOrderBloc>().add(AcceptTaskEvent(taskId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PendingOrderBloc, TaskState>(
      listener: (context, state) {
        if (state is AcceptedTask) {
          print("accept");
          // Hiển thị dialog khi tạo đơn hàng thành công
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Thành công'),
                content: const Text('Nhận đơn thành công!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Đóng dialog
                      // Có thể thêm navigation về trang chủ hoặc trang đơn hàng ở đây
                    },
                    child: const Text('Đóng'),
                  ),
                ],
              );
            },
          );
        } else if (state is FailedAcceptingTask) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Thất bại'),
                content: Text('Không thể nhận đơn: ${state.error}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Đóng'),
                  ),
                ],
              );
            },
          );
        }
      },
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Danh sách đơn hàng có thể nhận',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              RefreshIndicator(
                onRefresh: widget.reload,
                child: widget.tasks.isNotEmpty
                    ? Column(
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.6,
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: widget.tasks.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(),
                              itemBuilder: (context, index) {
                                final task = widget.tasks[index];
                                return _buildTaskCard(context, task);
                              },
                            ),
                          ),
                          ElevatedButton(
                            onPressed: widget.isLoading
                                ? null
                                : () {
                                    widget.onLoadMore();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  widget.isLoading ? Colors.grey : mainColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: widget.isLoading
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
                        ],
                      )
                    : const Center(
                        child: Column(
                          children: [
                            Image(
                              image: AssetImage("lib/assets/done.png"),
                              height: 350,
                            ),
                            Text(
                              'Hiện chưa có đơn hàng!',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            SizedBox(height: 200)
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void acceptTaskPopup(BuildContext context, bool isSuccess, String message) {
    // Đảm bảo dialog được gọi sau khi build hoàn tất
    if (isSuccess) {
      context.read<TaskBlocShipReceive>().add(StartTask());
      context.read<TaskBlocShipSend>().add(StartTask());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title:
                Text(isSuccess ? 'Nhận đơn thành công' : 'Nhận đơn thất bại!'),
            content: isSuccess
                ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          spreadRadius: 4,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      radius: 30,
                      child: const Icon(
                        Icons.done_outline_sharp,
                        color: Colors.green,
                        size: 30,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      Text(message),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              spreadRadius: 4,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.red.shade100,
                          radius: 30,
                          child: const Icon(
                            Icons.do_not_disturb_outlined,
                            color: Colors.red,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ), // Hiển thị thông báo lỗi nếu thất bại
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng popup
                },
                child: const Text('Đồng ý'),
              ),
            ],
          );
        },
      );
    });
  }

  Widget _buildTaskCard(context, Task task) {
    return Card(
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        title: Text(
          task.order!.trackingNumber!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(task.order!.detailSource!),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            confirmTask(context, task.id!);
          },
          child: const Text(
            'Xác nhận',
            style: TextStyle(color: Colors.green),
          ),
        ),
      ),
    );
  }
}
