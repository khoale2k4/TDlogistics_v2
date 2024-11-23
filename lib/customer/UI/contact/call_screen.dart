import 'package:flutter/material.dart';

class CallScreen extends StatefulWidget {
  final String name;
  final String phoneNumber;

  const CallScreen({super.key, required this.name, required this.phoneNumber});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool isCalling = false;
  bool bigVolume = false;

  void _startCall() {
    setState(() {
      isCalling = true;
    });
  }

  void _toggleVolume() {
    setState(() {
      bigVolume = !bigVolume;
    });
  }

  void _endCall() {
    setState(() {
      isCalling = false;
    });
    Navigator.pop(context); // Quay lại trang chat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Hiển thị thông tin người dùng
            Column(
              children: [
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.red.shade200,
                  child:
                      const Icon(Icons.person, size: 80, color: Colors.white),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.phoneNumber,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            // Trạng thái cuộc gọi
            if (isCalling)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Đang gọi...",
                  style: TextStyle(color: Colors.green, fontSize: 20),
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Sẵn sàng gọi",
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              ),

            // Nút hành động
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isCalling)
                  FloatingActionButton(
                    onPressed: _startCall,
                    backgroundColor: Colors.green,
                    heroTag: 'startCall', // Gán tag duy nhất
                    child: const Icon(Icons.call, color: Colors.white),
                  )
                else
                  Row(
                    children: [
                      FloatingActionButton(
                        onPressed: _endCall,
                        backgroundColor: Colors.red,
                        heroTag: 'endCall', // Gán tag duy nhất
                        child: const Icon(Icons.call_end, color: Colors.white),
                      ),
                      const SizedBox(width: 20),
                      FloatingActionButton(
                        onPressed: _toggleVolume,
                        backgroundColor: Colors.white,
                        heroTag: 'toggleVolume', // Gán tag duy nhất
                        child: Icon(
                          bigVolume
                              ? Icons.volume_up_rounded
                              : Icons.volume_down,
                          color: Colors.black,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
