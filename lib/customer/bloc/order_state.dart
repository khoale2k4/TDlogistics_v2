// ignore_for_file: must_be_immutable

import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:tdlogistic_v2/core/models/order_model.dart';

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

class OrderLoading extends OrderState {}

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