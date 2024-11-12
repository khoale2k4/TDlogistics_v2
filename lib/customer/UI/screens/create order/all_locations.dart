import 'package:flutter/material.dart';
import 'package:tdlogistic_v2/customer/data/models/favorite_location.dart';

class AllLocationsPage extends StatelessWidget {
  final List<Location> locations;

  const AllLocationsPage({Key? key, required this.locations}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tất cả các địa điểm")),
      body: ListView.builder(
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final location = locations[index];
          return ListTile(
            title: Text(location.name ?? "Không xác định"),
            subtitle: Text(
              "Lat: ${location.lat}, Lng: ${location.lng}",
            ),
          );
        },
      ),
    );
  }
}
