import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tdlogistic_v2/customer/bloc/order_bloc.dart';
import 'package:tdlogistic_v2/customer/bloc/order_event.dart';
import 'package:tdlogistic_v2/customer/bloc/order_state.dart';

class TaskRouteWidget extends StatefulWidget {
  final String orderId;

  const TaskRouteWidget({super.key, required this.orderId});

  @override
  _TaskRouteWidgetState createState() => _TaskRouteWidgetState();
}

class _TaskRouteWidgetState extends State<TaskRouteWidget> {
  late GoogleMapController mapController;
  Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  List<LatLng> _routePoints = [];

  @override
  void initState() {
    super.initState();
    // Trigger the event to fetch position data for the given orderId
    context.read<GetPositionsBloc>().add(GetPositions(widget.orderId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GetPositionsBloc, OrderState>(
        builder: (context, state) {
          if (state is GettingPositions) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GotPositions) {
            _routePoints = state.pos;
            _setPolylinesAndMarkers();

            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _routePoints.isNotEmpty ? _routePoints.first : const LatLng(0, 0),
                zoom: 12.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              markers: _markers,
              polylines: _polylines,
            );
          } else if (state is FailedGetPositions) {
            return Center(child: Text('Failed to load route: ${state.error}'));
          } else {
            return const Center(child: Text('No route data available.'));
          }
        },
      ),
    );
  }

  void _setPolylinesAndMarkers() {
    setState(() {
      // Clear previous markers and polylines
      _polylines.clear();
      _markers.clear();

      // Add polyline connecting the points
      _polylines.add(
        Polyline(
          polylineId: PolylineId(widget.orderId),
          points: _routePoints,
          color: Colors.blue,
          width: 5,
        ),
      );

      // Add markers for each point
      for (var point in _routePoints) {
        _markers.add(
          Marker(
            markerId: MarkerId('${point.latitude}-${point.longitude}'),
            position: point,
            infoWindow: InfoWindow(
              title: 'Lat: ${point.latitude}, Long: ${point.longitude}',
            ),
          ),
        );
      }
    });
  }
}
