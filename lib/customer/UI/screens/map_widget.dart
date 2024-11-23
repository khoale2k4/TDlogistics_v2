import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tdlogistic_v2/core/constant.dart';
import 'package:tdlogistic_v2/customer/bloc/order_bloc.dart';
import 'package:tdlogistic_v2/customer/bloc/order_event.dart';
import 'package:tdlogistic_v2/customer/bloc/order_state.dart';

class TaskRouteWidget extends StatefulWidget {
  final String orderId;

  const TaskRouteWidget({Key? key, required this.orderId}) : super(key: key);

  @override
  _TaskRouteWidgetState createState() => _TaskRouteWidgetState();
}

class _TaskRouteWidgetState extends State<TaskRouteWidget> {
  GoogleMapController? mapController;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  List<LatLng> _routePoints = [];
  double _currentZoom = 12.0;

  @override
  void initState() {
    super.initState();
    context.read<GetPositionsBloc>().add(GetPositions(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: const Text(
          'Chi tiết lộ trình',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          BlocBuilder<GetPositionsBloc, OrderState>(
            builder: (context, state) {
              if (state is GettingPositions) {
                return _buildLoadingIndicator();
              } else if (state is GotPositions) {
                _routePoints = state.pos;
                return _buildMap();
              }
              return const Center(child: Text('Không có dữ liệu'));
            },
          ),
          _buildZoomControls(),
          _buildInfoPanel(),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(secondColor),
      ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: _routePoints.isNotEmpty
            ? _routePoints.first
            : const LatLng(10.8231, 106.6297),
        zoom: _currentZoom,
      ),
      onMapCreated: (GoogleMapController controller) {
        setState(() {
          mapController = controller;
          _updateMapData();
        });
      },
      markers: _markers,
      polylines: _polylines,
    );
  }

  Positioned _buildZoomControls() {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: "zoom_in",
            mini: true,
            backgroundColor: secondColor,
            tooltip: 'Phóng to',
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              _currentZoom = min(_currentZoom + 1, 20);
              mapController?.animateCamera(
                CameraUpdate.zoomTo(_currentZoom),
              );
            },
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: "zoom_out",
            mini: true,
            backgroundColor: secondColor,
            tooltip: 'Thu nhỏ',
            child: const Icon(Icons.remove, color: Colors.white),
            onPressed: () {
              _currentZoom = max(_currentZoom - 1, 1);
              mapController?.animateCamera(
                CameraUpdate.zoomTo(_currentZoom),
              );
            },
          ),
        ],
      ),
    );
  }

  Positioned _buildInfoPanel() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 200,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   'Mã đơn hàng: ${widget.orderId}',
              //   style: TextStyle(
              //     fontWeight: FontWeight.bold,
              //     color: mainColor,
              //     fontSize: 16,
              //   ),
              // ),
              const SizedBox(height: 8),
              Text(
                'Khoảng cách: ${_calculateDistance()} km',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              Text(
                'Đã di chuyển: ${_calculateETA()} phút',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateDistance() {
    return '1.3'; // Giá trị ví dụ
  }

  String _calculateETA() {
    return '18'; // Giá trị ví dụ
  }

  void _updateMapData() async {
    if (_routePoints.isEmpty) return;

    // Cập nhật polyline
    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: PolylineId(widget.orderId),
        points: _routePoints,
        color: mainColor,
        width: 5,
      ),
    );

    // Cập nhật marker
    _markers.clear();
    if (_routePoints.isNotEmpty) {
      final lastPoint = _routePoints.last;

      final currentPositionIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/current_position_icon.png',
      );

      _markers.add(
        Marker(
          markerId: const MarkerId('current_position'),
          position: lastPoint,
          icon: currentPositionIcon,
          infoWindow: InfoWindow(
            title: 'Vị trí hiện tại',
            snippet: '${lastPoint.latitude}, ${lastPoint.longitude}',
          ),
        ),
      );
    }

    // Cập nhật vị trí camera để hiển thị toàn bộ tuyến đường
    if (mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          _getBounds(_routePoints),
          50.0,
        ),
      );
    }
  }

  LatLngBounds _getBounds(List<LatLng> points) {
    double? minLat, maxLat, minLng, maxLng;

    for (LatLng point in points) {
      minLat = minLat == null ? point.latitude : min(minLat, point.latitude);
      maxLat = maxLat == null ? point.latitude : max(maxLat, point.latitude);
      minLng = minLng == null ? point.longitude : min(minLng, point.longitude);
      maxLng = maxLng == null ? point.longitude : max(maxLng, point.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }
}
