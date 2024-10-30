// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';
import 'package:tdlogistic_v2/core/models/order_model.dart';
import 'package:tdlogistic_v2/customer/data/models/create_order.dart';

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
  final String? provinceSource;
  final String? districtSource;
  final String? detailSource;
  final String? provinceDestination;
  final String? districtDestination;
  final String? detailDestination;
  final String? deliveryMethod;
  final num? height;
  final num? width;
  final num? length;
  final num? mass;
  
  const CalculateFee(this.provinceSource, this.districtSource, this.detailSource, this.provinceDestination, this.districtDestination, this.detailDestination, this.deliveryMethod, this.height, this.length, this.mass, this.width);
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

  const CreateOrderEvent(this.order);

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
