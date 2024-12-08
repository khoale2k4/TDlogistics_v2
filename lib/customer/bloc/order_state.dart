// ignore_for_file: must_be_immutable

import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tdlogistic_v2/core/models/chats_model.dart';
import 'package:tdlogistic_v2/core/models/order_model.dart';
import 'package:tdlogistic_v2/customer/data/models/voucher.dart';
import 'package:tdlogistic_v2/customer/data/models/favorite_location.dart';
import 'package:tdlogistic_v2/customer/data/models/shipping_bill.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderFeeCalculating extends OrderState {}

class OrderFeeCalculated extends OrderState {
  final num fee;

  const OrderFeeCalculated(this.fee);
}

class OrderFeeCalculationFailed extends OrderState {
  final String error;

  const OrderFeeCalculationFailed(this. error);
}

class OrderLoading extends OrderState {
  final List<Order> orders;

  OrderLoading(this.orders);
}

class OrderLoaded extends OrderState {
  final List<Order> orders;
  final int totalOrders;
  int page = 1;

  OrderLoaded(this.orders, this.totalOrders, {this.page = 1});

  @override
  List<Object?> get props => [orders, totalOrders];
}

class OrderDetailLoaded extends OrderState {
  final Order order;

  const OrderDetailLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderCreating extends OrderState {

}

class OrderCreated extends OrderState {}

class OrderCreateFaild extends OrderState {
  final String error;

  OrderCreateFaild(this.error);
}

class OrderUpdated extends OrderState {
  final Order order;

  const OrderUpdated(this.order);

  @override
  List<Object?> get props => [order];
}

class OrderDeleted extends OrderState {}

class OrderError extends OrderState {
  final String error;

  const OrderError(this.error);

  @override
  List<Object?> get props => [error];
}

class GettingImages extends OrderState{}

class GotImages extends OrderState{
  late List<Uint8List> sendImages;
  late List<Uint8List> receiveImages;
  late Uint8List? sendSignature;
  late Uint8List? receiveSignature;

  GotImages(this.receiveImages, this.receiveSignature, this.sendImages, this.sendSignature);
}

class FailedImage extends OrderState{
  final String error;

  FailedImage(this.error);
}

class FailGettingLocations extends OrderState{
  String error;

  FailGettingLocations(this.error);
}

class GotLocations extends OrderState{
  List<Location> locations = [];
  List<FavoriteLocation> favLocations = [];

  GotLocations({required this.locations, required this.favLocations});
}

class GettingLocations extends OrderState{}

class GettingPositions extends OrderState{}

class GotPositions extends OrderState{
  final List<LatLng> pos;

  GotPositions(this.pos);
}

class FailedGetPositions extends OrderState{
  final String error;

  FailedGetPositions(this.error);
}

class CreatedShippingBill extends OrderState{}

class FailedCreatingBill extends OrderState{
  final String error;

  FailedCreatingBill(this.error);
}

class GotShippingBill extends OrderState{
  final ShippingBill sb;
  GotShippingBill(this.sb);
}

class FailedGettingBill extends OrderState{
  final String error;

  FailedGettingBill(this.error);
}

class GetChatsSuccess extends OrderState{
  final List<Chat> chats;

  const GetChatsSuccess(this.chats);
}

class GetChatsFailure extends OrderState{
  final String error;

  const GetChatsFailure(this.error);
}

class GetChatWithShipSuccess extends OrderState{
  final List<Message> messages;

  const GetChatWithShipSuccess(this.messages);
}

class GetChatWithShipFailure extends OrderState{
  final String error;

  const GetChatWithShipFailure(this.error);
}

class ReceiveMessage extends OrderState {
  final Map<String, dynamic> message;

  ReceiveMessage(this.message);
}

class GotId extends OrderState {
  final String id;

  const GotId(this.id);
}

class GotVouchers extends OrderState {
  final List<Voucher> vouchers;

  const GotVouchers(this.vouchers);
}
