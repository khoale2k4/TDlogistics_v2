import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlogistic_v2/core/models/order_model.dart';
import 'package:tdlogistic_v2/core/service/secure_storage_service.dart';
import 'package:tdlogistic_v2/customer/data/models/calculate_fee_payload.dart';
import 'order_event.dart';
import 'order_state.dart';
import '../../core/repositories/order_repository.dart';

class OrderBlocCus extends Bloc<OrderEvent, OrderState> {
  final SecureStorageService secureStorageService;
  final OrderRepository orderRepository = OrderRepository();

  OrderBlocCus(
      {required this.secureStorageService})
      : super(OrderLoading()) {
    on<StartOrder>(getOrder);
  }

  Future<void> getOrder(StartOrder event, Emitter<OrderState> emit) async {
    emit(OrderLoading());

    try {
      final fetchOrder = await orderRepository
          .getOrders((await secureStorageService.getToken())!);
      List<dynamic> fetchedOrders = fetchOrder["data"];
      List<Order> orders = [];
      if (fetchOrder["success"]) {
        for (int i = 0; i < fetchedOrders.length; i++) {
          // print(fetchedOrders[i]);
          orders.add(Order.fromJson(fetchedOrders[i]));
        }
      }
      emit(OrderLoaded(orders, orders.length));
    } catch (error) {
      emit(OrderError(error.toString()));
    }
  }
}

class OrderBlocSearchCus extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository = OrderRepository();
  final SecureStorageService secureStorageService;

  OrderBlocSearchCus(
      {required this.secureStorageService})
      : super(OrderLoading()) {
    on<GetOrders>(getOrrder);
  }

  Future<void> getOrrder(event, emit) async {
    print("Getting order");
    if (event.status == 1) print("status = 1");
    emit(OrderLoading());
    try {
      final fetchOrder = await orderRepository
          .getOrders((await secureStorageService.getToken())!);
      List<dynamic> fetchedOrders = fetchOrder["data"];
      List<Order> orders = [];
      if (fetchOrder["success"]) {
        for (int i = 0; i < fetchedOrders.length; i++) {
          // print(fetchedOrders[i]);
          orders.add(Order.fromJson(fetchedOrders[i]));
        }
      }
      emit(OrderLoaded(orders, orders.length));
    } catch (error) {
      emit(OrderError(error.toString()));
    }
  }
}

class OrderBlocFee extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository = OrderRepository();

  OrderBlocFee() : super(OrderLoading()) {
    on<CalculateFee>(calculateFee);
  }
  Future<void> calculateFee(event, emit) async {
    emit(OrderFeeCalculating()); // Trạng thái đang tính phí
    try {
      final fee = await orderRepository.calculateFee(CalculateFeePayload(
        event.provinceSource,
        event.districtSource,
        event.detailSource,
        event.provinceDestination,
        event.districtDestination,
        event.detailDestination,
        event.deliveryMethod,
        event.height,
        event.length,
        event.mass,
        event.width,
      ));

      print(fee);

      if (fee["success"]) {
        emit(OrderFeeCalculated(fee["data"])); // Thành công
      } else {
        emit(OrderFeeCalculationFailed(fee["message"])); // Thất bại
      }
    } catch (error) {
      emit(OrderFeeCalculationFailed(error.toString())); // Xử lý lỗi
    }
  }
}

class GetImagesBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository = OrderRepository();
  final SecureStorageService secureStorageService;

  GetImagesBloc({required this.secureStorageService})
      : super(GettingImages()) {
    on<GetOrderImages>(getImages);
  }

  Future<void> getImages(event, emit) async {
    emit(GettingImages());

    try {
      final order = await orderRepository.getOrderById(
          event.orderId, (await secureStorageService.getToken())!);
      if (order["success"]) {
        List<Uint8List> send = [];
        List<Uint8List> receive = [];
        Uint8List? sendSig;
        Uint8List? receiveSig;

        final imageIds = order["data"][0]["images"];
        for (int i = 0; i < imageIds.length; i++) {
          bool isSend = (imageIds[i]["type"] == "SEND");
          final imageRs = await orderRepository.getOrderImageById(
              imageIds[i]["id"], (await secureStorageService.getToken())!);
          if (isSend) {
            send.add(imageRs["data"]);
          } else {
            receive.add(imageRs["data"]);
          }
        }

        final sigImageIds = order["data"][0]["signatures"];
        for (int i = 0; i < sigImageIds.length; i++) {
          bool isSend = (sigImageIds[i]["type"] == "SEND");
          final imageRs = await orderRepository.getOrderImageById(
              imageIds[i]["id"], (await secureStorageService.getToken())!);
          if (isSend) {
            sendSig = imageRs["data"];
          } else {
            receiveSig = imageRs["data"];
          }
        }
        emit(GotImages(receive, receiveSig, send, sendSig));
      } else {
        emit(GotImages(const [], null, const [], null));
      }
    } catch (error) {
      print("Error getting images: ${error.toString()}");
      emit(GotImages(const [], null, const [], null));
    }
  }
}

class ProcessingOrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository = OrderRepository();
  final SecureStorageService secureStorageService;

  ProcessingOrderBloc(
      {required this.secureStorageService})
      : super(OrderLoading()) {
    on<StartOrder>(getOrder);
    on<AddOrder>(addOrder);
  }

  Future<void> getOrder(event, emit) async {
    print("Getting order");
    emit(OrderLoading());
    try {
      final fetchOrder = await orderRepository.getOrders(
          (await secureStorageService.getToken())!,
          status: "PROCESSING");
      List<dynamic> fetchedOrders = fetchOrder["data"];
      List<Order> orders = [];
      if (fetchOrder["success"]) {
        for (int i = 0; i < fetchedOrders.length; i++) {
          // print(fetchedOrders[i]);
          orders.add(Order.fromJson(fetchedOrders[i]));
        }
      }
      emit(OrderLoaded(orders, orders.length));
    } catch (error) {
      emit(OrderError(error.toString()));
    }
  }

  void addOrder(AddOrder event, Emitter<OrderState> emit) async {
    if (state is OrderLoaded) {
      final currentState = state as OrderLoaded;
      emit(OrderLoading());
      final updatedOrders = List<Order>.from(currentState.orders);
      print(currentState.page);
      final newPage = currentState.page + 1;

      final fetchOrder = await orderRepository.getOrders(
        (await secureStorageService.getToken())!,
        status: "PROCESSING",
        page: newPage,
      );

      List<dynamic> fetchedOrders = fetchOrder["data"];
      if (fetchOrder["success"]) {
        for (int i = 0; i < fetchedOrders.length; i++) {
          updatedOrders.add(Order.fromJson(fetchedOrders[i]));
        }
      }
      emit(OrderLoaded(updatedOrders, updatedOrders.length, page: newPage));
    }
  }
}

class TakingOrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository = OrderRepository();
  final SecureStorageService secureStorageService;

  TakingOrderBloc(
      {required this.secureStorageService})
      : super(OrderLoading()) {
    on<StartOrder>(getOrder);
    on<AddOrder>(addOrder);
  }

  Future<void> getOrder(event, emit) async {
    print("Getting order");
    emit(OrderLoading());
    try {
      final fetchOrder = await orderRepository.getOrders(
          (await secureStorageService.getToken())!,
          status: "TAKING");
      List<dynamic> fetchedOrders = fetchOrder["data"];
      List<Order> orders = [];
      if (fetchOrder["success"]) {
        for (int i = 0; i < fetchedOrders.length; i++) {
          // print(fetchedOrders[i]);
          orders.add(Order.fromJson(fetchedOrders[i]));
        }
      }
      emit(OrderLoaded(orders, orders.length));
    } catch (error) {
      emit(OrderError(error.toString()));
    }
  }

  void addOrder(AddOrder event, Emitter<OrderState> emit) async {
    if (state is OrderLoaded) {
      final currentState = state as OrderLoaded;
      emit(OrderLoading());
      final updatedOrders = List<Order>.from(currentState.orders);
      print(currentState.page);
      final newPage = currentState.page + 1;

      final fetchOrder = await orderRepository.getOrders(
        (await secureStorageService.getToken())!,
        status: "PROCESSING",
        page: newPage,
      );

      List<dynamic> fetchedOrders = fetchOrder["data"];
      if (fetchOrder["success"]) {
        for (int i = 0; i < fetchedOrders.length; i++) {
          updatedOrders.add(Order.fromJson(fetchedOrders[i]));
        }
      }
      emit(OrderLoaded(updatedOrders, updatedOrders.length, page: newPage));
    }
  }
}

class DeliveringOrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository = OrderRepository();
  final SecureStorageService secureStorageService;

  DeliveringOrderBloc(
      {required this.secureStorageService})
      : super(OrderLoading()) {
    on<StartOrder>(getOrder);
    on<AddOrder>(addOrder);
  }

  Future<void> getOrder(event, emit) async {
    print("Getting order");
    emit(OrderLoading());
    try {
      final fetchOrder = await orderRepository.getOrders(
          (await secureStorageService.getToken())!,
          status: "DELIVERING");
      List<dynamic> fetchedOrders = fetchOrder["data"];
      List<Order> orders = [];
      if (fetchOrder["success"]) {
        for (int i = 0; i < fetchedOrders.length; i++) {
          // print(fetchedOrders[i]);
          orders.add(Order.fromJson(fetchedOrders[i]));
        }
      }
      emit(OrderLoaded(orders, orders.length));
    } catch (error) {
      emit(OrderError(error.toString()));
    }
  }

  void addOrder(AddOrder event, Emitter<OrderState> emit) async {
    if (state is OrderLoaded) {
      final currentState = state as OrderLoaded;
      emit(OrderLoading());
      final updatedOrders = List<Order>.from(currentState.orders);
      print(currentState.page);
      final newPage = currentState.page + 1;

      final fetchOrder = await orderRepository.getOrders(
        (await secureStorageService.getToken())!,
        status: "PROCESSING",
        page: newPage,
      );

      List<dynamic> fetchedOrders = fetchOrder["data"];
      if (fetchOrder["success"]) {
        for (int i = 0; i < fetchedOrders.length; i++) {
          updatedOrders.add(Order.fromJson(fetchedOrders[i]));
        }
      }
      emit(OrderLoaded(updatedOrders, updatedOrders.length, page: newPage));
    }
  }
}

class CancelledOrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository = OrderRepository();
  final SecureStorageService secureStorageService;

  CancelledOrderBloc(
      {required this.secureStorageService})
      : super(OrderLoading()) {
    on<StartOrder>(getOrder);
    on<AddOrder>(addOrder);
  }

  Future<void> getOrder(event, emit) async {
    print("Getting order");
    emit(OrderLoading());
    try {
      final fetchOrder = await orderRepository.getOrders(
          (await secureStorageService.getToken())!,
          status: "CANCEL");
      List<dynamic> fetchedOrders = fetchOrder["data"];
      List<Order> orders = [];
      if (fetchOrder["success"]) {
        for (int i = 0; i < fetchedOrders.length; i++) {
          // print(fetchedOrders[i]);
          orders.add(Order.fromJson(fetchedOrders[i]));
        }
      }
      emit(OrderLoaded(orders, orders.length));
    } catch (error) {
      emit(OrderError(error.toString()));
    }
  }

  void addOrder(AddOrder event, Emitter<OrderState> emit) async {
    if (state is OrderLoaded) {
      final currentState = state as OrderLoaded;
      emit(OrderLoading());
      final updatedOrders = List<Order>.from(currentState.orders);
      print(currentState.page);
      final newPage = currentState.page + 1;

      final fetchOrder = await orderRepository.getOrders(
        (await secureStorageService.getToken())!,
        status: "PROCESSING",
        page: newPage,
      );

      List<dynamic> fetchedOrders = fetchOrder["data"];
      if (fetchOrder["success"]) {
        for (int i = 0; i < fetchedOrders.length; i++) {
          updatedOrders.add(Order.fromJson(fetchedOrders[i]));
        }
      }
      emit(OrderLoaded(updatedOrders, updatedOrders.length, page: newPage));
    }
  }
}

class CompletedOrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository = OrderRepository();
  final SecureStorageService secureStorageService;

  CompletedOrderBloc(
      {required this.secureStorageService})
      : super(OrderLoading()) {
    on<StartOrder>(getOrder);
    on<AddOrder>(addOrder); // Thêm sự kiện mới cho việc thêm đơn hàng
  }

  Future<void> getOrder(event, emit) async {
    print("Getting order");
    emit(OrderLoading());
    try {
      final fetchOrder = await orderRepository.getOrders(
          (await secureStorageService.getToken())!,
          status: "DELIVERED_SUCCESS");
      List<dynamic> fetchedOrders = fetchOrder["data"];
      List<Order> orders = [];
      if (fetchOrder["success"]) {
        for (int i = 0; i < fetchedOrders.length; i++) {
          orders.add(Order.fromJson(fetchedOrders[i]));
        }
      }
      emit(OrderLoaded(orders, orders.length));
    } catch (error) {
      emit(OrderError(error.toString()));
    }
  }

  void addOrder(AddOrder event, Emitter<OrderState> emit) async {
    if (state is OrderLoaded) {
      final currentState = state as OrderLoaded;
      emit(OrderLoading());
      final updatedOrders = List<Order>.from(currentState.orders);
      print(currentState.page);
      final newPage = currentState.page + 1;

      final fetchOrder = await orderRepository.getOrders(
        (await secureStorageService.getToken())!,
        status: "PROCESSING",
        page: newPage,
      );

      List<dynamic> fetchedOrders = fetchOrder["data"];
      if (fetchOrder["success"]) {
        for (int i = 0; i < fetchedOrders.length; i++) {
          updatedOrders.add(Order.fromJson(fetchedOrders[i]));
        }
      }
      emit(OrderLoaded(updatedOrders, updatedOrders.length, page: newPage));
    }
  }
}
