// ignore_for_file: must_be_immutable

import 'dart:io';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:tdlogistic_v2/core/models/order_model.dart';
import 'package:tdlogistic_v2/customer/data/models/cargo_insurance.dart';
import 'package:tdlogistic_v2/customer/data/models/create_order.dart';
import 'package:tdlogistic_v2/customer/data/models/favorite_location.dart';
import 'package:tdlogistic_v2/customer/data/models/shipping_bill.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class GetOrderImages extends OrderEvent{
  final String orderId;

  GetOrderImages(this.orderId);
}

class CalculateFee extends OrderEvent {
    final String serviceType;
    final int cod;
    final double  latSource;
    final double  longSource;
    final double  latDestination;
    final double  longDestination;
    final String? voucherId;
  
  const CalculateFee({required this.serviceType, required this.cod, required this.latSource, required this.longSource, required this.latDestination, required this.longDestination, this.voucherId});
}

class GetOrders extends OrderEvent {
  final String? id;
  final int? status;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int page;
  final int pageSize;

  const GetOrders({
    this.id,
    this.status,
    this.fromDate,
    this.toDate,
    this.page = 1,
    this.pageSize = 10,
  });

  @override
  List<Object?> get props => [id, status, fromDate, toDate, page, pageSize];
}

class CreateOrderEvent extends OrderEvent {
  final CreateOrderObject order;
  final List<Uint8List> files;
  late ShippingBill? sb;
  late CargoInsurance? ci;

  CreateOrderEvent(this.order, this.files, this.sb, this.ci);

  @override
  List<Object?> get props => [order];
}

class UpdateOrder extends OrderEvent {
  final Order order;

  const UpdateOrder(this.order);

  @override
  List<Object?> get props => [order];
}

class DeleteOrder extends OrderEvent {
  final String id;

  const DeleteOrder(this.id);

  @override
  List<Object?> get props => [id];
}

class StartOrder extends OrderEvent{
  final String id;
  final int status = 1;
  final DateTime fromDate = DateTime(0);
  final DateTime toDate = DateTime.now();
  final int page = 0;
  final int pageSize = 5;

  StartOrder({
    this.id = "",
  });

  @override
  List<Object?> get props => [id];
}

class AddOrder extends OrderEvent{
  final List<Order> orders;
  int page = 1;

  AddOrder(this.orders, this.page);
}

class GetLocations extends OrderEvent{}

class AddLocation extends OrderEvent{
  Location? loc;
  FavoriteLocation? faLoc;

  AddLocation({this.loc, this.faLoc});
}

class GetPositions extends OrderEvent {
  final String orderId;
  
  const GetPositions(this.orderId);
}

class CreateShippingBill extends OrderEvent{
  final ShippingBill sb;

  CreateShippingBill(this.sb);
}

class GetShippingBill extends OrderEvent{}

class UpdateFavoriteLocation extends OrderEvent{
  final FavoriteLocation favLoc;

  UpdateFavoriteLocation(this.favLoc);
}

class UpdateLocation extends OrderEvent{
  final Location loc;

  UpdateLocation(this.loc);
}

class DeleteLocation extends OrderEvent{
  final String locationId;
  final bool isFav;

  DeleteLocation(this.locationId, {this.isFav = false});
}


class GetChatWithShip extends OrderEvent{
  final String receiverId;
  final int page;
  final int size;

  const GetChatWithShip({required this.receiverId, this.page = 1, this.size = 12});
}

class GetChats extends OrderEvent{
  final int page;
  final int size;

  const GetChats({this.page = 1, this.size = 12});
}

class NewMessage extends OrderEvent {
  final String newMess;
  final String receiverId;

  const NewMessage(this.newMess, this.receiverId);
}

class GetId extends OrderEvent {
  final String id;

  const GetId(this.id);
}

class GetVouchers extends OrderEvent {
  final int page;
  final int size;

  const GetVouchers({this.page = 1, this.size = 12});
}
