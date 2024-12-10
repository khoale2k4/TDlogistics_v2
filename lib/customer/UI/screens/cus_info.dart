import 'package:easy_localization/easy_localization.dart';
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

  void _changeLanguage(String langCode) {
    Locale newLocale =
        langCode == 'vi' ? const Locale('vi', '') : const Locale('en', '');
    context.setLocale(newLocale);
  }

  Widget buildLanguageButton(String langCode, String label) {
    return ElevatedButton(
      onPressed: () => _changeLanguage(langCode),
      child: Text(label),
    );
  }

  Widget _buildLanguageButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language, color: Colors.white),
      onSelected: (String langCode) {
        _changeLanguage(langCode);
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem(
          value: 'vi',
          child: Text('Tiếng Việt'),
        ),
        const PopupMenuItem(
          value: 'en',
          child: Text('English'),
        ),
      ],
    );
  }

  Widget logoutButton() {
    return TextButton(
      onPressed: () {
        _showLogoutDialog(context);
      },
      child: Text(context.tr("logout"), style: TextStyle(color: Colors.red)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr("greeting"),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          _buildLanguageButton(),
        ],
        elevation: 2,
        backgroundColor: mainColor,
      ),
      backgroundColor: Colors.white,
      body: BlocListener<UserBloc, AuthState>(
        listener: (context, state) {
          if (state is UpdatingInfo) {
          } else if (state is UpdatedInfo) {
            // Hiển thị thông báo thành công
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.tr("successSaveInfo")),
                backgroundColor: secondColor,
              ),
            );
          } else if (state is FailedUpdateInfo) {
            // Hiển thị thông báo lỗi
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.tr("failedSaveInfo")),
                backgroundColor: mainColor,
              ),
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
                buildFieldText(context, context.tr("lastName"), firstNameController),
                const SizedBox(height: 20),
                buildFieldText(context, context.tr("firstName"), lastNameController),
                const SizedBox(height: 20),
                buildFieldText(context, context.tr("phone"), phoneController),
                const SizedBox(height: 20),
                buildFieldText(context, "Email", emailController),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    context.read<UserBloc>().add(
                          UpdateInfo(
                            email: emailController.text,
                            fName: firstNameController.text,
                            lName: lastNameController.text,
                          ),
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor, // Thay đổi màu nền của nút
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Border radius
                    ),
                  ),
                  child: Text(
                    context.tr("save"),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),
                logoutButton(),
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
          title: Text(context.tr("confirmLogout")),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(context.tr("deny")),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(LogoutRequested());
                Navigator.of(context).pop();
              },
              child: Text(context.tr("confirm")),
            ),
          ],
        );
      },
    );
  }

  Widget buildFieldText(
      BuildContext context, String title, TextEditingController controller) {
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
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              enabled: title == "Số điện thoại" ? false : true,
            ),
          ),
        ],
      ),
    );
  }
}
