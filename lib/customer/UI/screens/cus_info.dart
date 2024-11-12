import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_bloc.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_event.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_state.dart';
import 'package:tdlogistic_v2/auth/data/models/user_model.dart';
import 'package:tdlogistic_v2/core/constant.dart';

class CustomerInfor extends StatefulWidget {
  final User user;
  const CustomerInfor({super.key, required this.user});

  @override
  State<CustomerInfor> createState() => _CustomerInforState();
}

class _CustomerInforState extends State<CustomerInfor> {
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController firstNameController;

  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController(text: widget.user.firstName);
    lastNameController = TextEditingController(text: widget.user.lastName);
    phoneController = TextEditingController(text: widget.user.phoneNumber);
    emailController = TextEditingController(text: widget.user.email);
  }

  void handleLogoutButton() {
    context.read<AuthBloc>().add(LogoutRequested());
  }

  void handleChangeAvatar() {
    print("Changing avatar");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Xin chào!",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
        elevation: 2,
        backgroundColor: mainColor,
      ),
      backgroundColor: Colors.white,
      body: BlocListener<UserBloc, AuthState>(
        listener: (context, state) {
          if (state is UpdatingInfo) {
            // Hiển thị một thông báo khi đang cập nhật thông tin
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Đang cập nhật thông tin...")),
            );
          } else if (state is UpdatedInfo) {
            // Hiển thị thông báo thành công
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Cập nhật thông tin thành công!"), backgroundColor: secondColor,),
            );
          } else if (state is FailedUpdateInfo) {
            // Hiển thị thông báo lỗi
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Cập nhật thông tin thất bại!"), backgroundColor: mainColor,),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: handleChangeAvatar,
                  child: const CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: 55,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage("lib/assets/avt.jpg"),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 16,
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                buildFieldText(context, "Họ", firstNameController),
                const SizedBox(height: 20),
                buildFieldText(context, "Tên", lastNameController),
                const SizedBox(height: 20),
                buildFieldText(context, "Số điện thoại", phoneController),
                const SizedBox(height: 20),
                buildFieldText(context, "Email", emailController),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    context.read<UserBloc>().add(
                          UpdateInfo(
                            email: emailController.text,
                            fName: firstNameController .text,
                            lName: lastNameController.text,
                          ),
                        );
                  },
                  child: const Text('Lưu'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bạn muốn đăng xuất?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(LogoutRequested());
                Navigator.of(context).pop();
              },
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
    );
  }

  Widget buildFieldText(BuildContext context, String title, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 246, 246, 246),
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: secondColor),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              enabled: title == "Số điện thoại" ? false : true,
            ),
          ),
        ],
      ),
    );
  }
}