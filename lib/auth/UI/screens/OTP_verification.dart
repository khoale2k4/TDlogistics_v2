import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_bloc.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_event.dart';
import 'package:tdlogistic_v2/core/constant.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final String phone;
  final String msg;
  final String id;

  const OtpVerificationPage(
      {super.key,
      required this.email,
      required this.phone,
      required this.msg,
      required this.id});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.msg != "") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.msg),
          backgroundColor: mainColor,
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xác minh OTP'),
        leading: IconButton(
          onPressed: () {
            context.read<AuthBloc>().add(Back(widget.email, widget.phone));
          },
          icon: const Icon(Icons.chevron_left, size: 30),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  TextField(
                    onChanged: (value) => {
                      if (value.length >= 6)
                        {
                          context.read<AuthBloc>().add(VerifyOtp(
                              widget.email, widget.phone, value, widget.id))
                        }
                    },
                    controller: _otpController,
                    decoration: InputDecoration(
                      labelText: 'Nhập mã OTP',
                      prefixIcon: const Icon(Icons.security),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthBloc>().add(SendOtpRequest(
                      widget.email, widget.phone)); // Xác minh OTP
                },
                child: const Text('Gửi lại OTP'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
