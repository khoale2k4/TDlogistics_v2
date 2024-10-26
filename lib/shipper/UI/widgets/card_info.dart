import 'package:flutter/material.dart';

class CardInfo extends StatefulWidget {
  final String title;
  final String info;
  const CardInfo({
    super.key,
    required this.title,
    required this.info,
  });

  @override
  State<CardInfo> createState() => _CardInfoState();
}

class _CardInfoState extends State<CardInfo> {
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
          widget.info == "Chưa có thông tin"
              ? const Text(
                  "Chưa có thông tin",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 193, 193, 193),
                  ),
                )
              : Text(
                  widget.info,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
        ],
      ),
    );
  }
}
