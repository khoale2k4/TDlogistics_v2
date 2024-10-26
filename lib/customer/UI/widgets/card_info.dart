import 'package:flutter/material.dart';

class CardInfo extends StatefulWidget {
  final String title;
  final String info;
  final Function(String) onButtonPressed; // Callback function

  const CardInfo({
    super.key,
    required this.title,
    required this.info,
    required this.onButtonPressed,
  });

  @override
  State<CardInfo> createState() => _CardInfoState();
}

class _CardInfoState extends State<CardInfo> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.info; // Initialize the text field with the info
  }

  @override
  Widget build(BuildContext context) {
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
            widget.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          TextField(
            controller: _controller,
          ),
          // const SizedBox(height: 10),
          // ElevatedButton(
          //   onPressed: () {
          //     widget.onButtonPressed(_controller.text); // Call the callback
          //   },
          //   child: const Text('Cập nhật'),
          // ),
        ],
      ),
    );
  }
}