import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlogistic_v2/auth/data/models/user_model.dart';
import 'package:tdlogistic_v2/shipper/UI/screens/chat_box.dart';
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

  ShipperNavigatePage({super.key, required this.user, required this.tasks});

  @override
  _ShipperNavigatePageState createState() => _ShipperNavigatePageState();
}

class _ShipperNavigatePageState extends State<ShipperNavigatePage> {
  int _currentIndex = 0; // Index hiện tại của bottom navigation
  late User user;

  // Các trang scaffold khác nhau
  List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _pages = [
      const TasksWidget(),
      const ShipperHistory(),
      const ChatBox(),
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
            icon: _buildIconWithCircle(Icons.message, 2),
            label: 'Tin nhắn',
          ),
          BottomNavigationBarItem(
            icon: _buildIconWithCircle(Icons.person, 3),
            label: 'Bạn',
          ),
        ],
        type: BottomNavigationBarType.fixed, // Đảm bảo các tab không bị cuộn
      ),
      floatingActionButton: Stack(
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
                      style: const TextStyle(
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
        return TasksNotifications(tasks: widget.tasks);
      },
    );
  }
}

class TasksNotifications extends StatefulWidget {
  final List<Task> tasks;
  const TasksNotifications({super.key, required this.tasks});

  @override
  State<TasksNotifications> createState() => _TasksNotificationsState();
}

class _TasksNotificationsState extends State<TasksNotifications> {
  void confirmTask(BuildContext context, String taskId) {
    context.read<AcceptTask>().add(AcceptTaskEvent(taskId));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
            // List orders
            BlocBuilder<PendingOrderBloc, TaskState>(
              builder: (context, state) {
                if (state is TaskLoaded) {
                  return state.tasks.isNotEmpty
                      ? ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.6,
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: state.tasks.length,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemBuilder: (context, index) {
                              final task = state.tasks[index];
                              return _buildTaskCard(context, task);
                            },
                          ),
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
                              )
                            ],
                          ),
                        );
                } else if (state is TaskError) {
                  return Text(state.error);
                }
                return const CircularProgressIndicator();
              },
            )
          ],
        ),
      ),
    );
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
