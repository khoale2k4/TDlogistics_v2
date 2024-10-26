import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_bloc.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_event.dart';
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
  @override
  void initState() {
    // TODO: implement initState

    lastNameController = TextEditingController(text: widget.user.lastName);
    phoneController = TextEditingController(text: widget.user.phoneNumber);
    emailController = TextEditingController(text: widget.user.email);
    super.initState();
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
          TextButton(
            onPressed: () {
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
                          context.read<AuthBloc>().add(
                                LogoutRequested(),
                              );
                          Navigator.of(context).pop();
                        },
                        child: const Text('Đăng xuất'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Icon(
              Icons.exit_to_app,
              color: Colors.white,
              size: 30,
            ),
          ),
        ],
        elevation: 2, // Adds slight shadow for visual separation
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: mainColor,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: handleChangeAvatar,
                child: const CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 55, // Increased for better look
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        AssetImage("lib/assets/avt.jpg") as ImageProvider,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: CircleAvatar(
                        // Wrap icon inside CircleAvatar for better visibility
                        backgroundColor: Colors.white,
                        radius: 16,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                          size: 20, // Reduced for better balance
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  buildFieldText(context, "Tên", lastNameController),
                  const SizedBox(
                    height: 20,
                  ),
                  buildFieldText(context, "Số điện thoại", phoneController),
                  const SizedBox(
                    height: 20,
                  ),
                  buildFieldText(context, "Email", emailController),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Lưu'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFieldText(
      BuildContext context, String title, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      width: MediaQuery.of(context).size.width - 120,
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
          ),
        ],
      ),
    );
  }
}
