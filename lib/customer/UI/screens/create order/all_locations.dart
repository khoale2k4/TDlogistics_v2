import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/core/service/google.dart';
import 'package:tdlogistic_v2/customer/UI/screens/create%20order/add_location.dart';
import 'package:tdlogistic_v2/customer/bloc/order_bloc.dart';
import 'package:tdlogistic_v2/customer/bloc/order_event.dart';
import 'package:tdlogistic_v2/customer/bloc/order_state.dart';
import 'package:tdlogistic_v2/customer/data/models/favorite_location.dart';

class AllLocationsPage extends StatefulWidget {
  const AllLocationsPage({Key? key}) : super(key: key);

  @override
  State<AllLocationsPage> createState() => _AllLocationsPageState();
}

class _AllLocationsPageState extends State<AllLocationsPage> {
  String getLabel(String name) {
    if (name == "COMPANY") {
      return "Công ty";
    } else if (name == "HOME") {
      return "Nhà";
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Các địa điểm đã lưu",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: mainColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: BlocBuilder<GetLocationBloc, OrderState>(
        builder: (context, state) {
          if (state is FailGettingLocations) {
            return Text("Lỗi: ${state.error}");
          } else if (state is GotLocations) {
            return Container(
              child: buildList(state.locations),
            );
          } else {
            return const Center(
              child: Text("Đang lấy các địa điểm"),
            );
          }
        },
      ),
      //
    );
  }

  Future<void> _editLocation(
      BuildContext context, Location loc, String address) async {
    // Logic to edit the location
    // For example:
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NewLocation(
                location: loc.name!,
                address: address,
                isEdit: true,
                locationId: loc.id!,
              )),
    );
    if (result != null) {
      print(result);
      final newLatLng = await getLatLngFromAddress(result[1]);
      if (newLatLng == null) return;
      setState(() {
        loc.lat = newLatLng["lat"];
        loc.lng = newLatLng["lng"];
        loc.name = result[0];
      });
      context.read<GetLocationBloc>().add(UpdateLocation(loc));
      // await Future.delayed(const Duration(seconds: 1));
      // context.read<GetLocationBloc>().add(GetLocations());
    }
  }

  Widget buildList(List<Location> locs) {
    return locs.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_off, size: 80, color: Colors.grey),
                SizedBox(height: 20),
                Text(
                  'Chưa có địa điểm nào được lưu',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: locs.length,
            itemBuilder: (context, index) {
              final location = locs[index];
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.black),
                  title: Text(
                    getLabel(location.name ?? "Không xác định"),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: FutureBuilder<String?>(
                    future:
                        convertLatLngToAddress(location.lat!, location.lng!),
                    builder: (BuildContext context,
                        AsyncSnapshot<String?> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Text("Đang tải");
                      } else if (snapshot.hasError) {
                        return Text('Đã xảy ra lỗi: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return const Text('Không tìm thấy địa chỉ');
                      } else {
                        return Text(
                          snapshot.data!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        );
                      }
                    },
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.black),
                        onPressed: () async {
                          final address = await convertLatLngToAddress(
                              location.lat!, location.lng!);
                          print(address);
                          _editLocation(context, location, address!);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
