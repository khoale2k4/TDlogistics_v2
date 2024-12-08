import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tdlogistic_v2/core/models/order_model.dart';
import 'package:tdlogistic_v2/core/repositories/chat_repository.dart';
import 'package:tdlogistic_v2/core/service/secure_storage_service.dart';
import 'package:tdlogistic_v2/core/service/send_location.dart';
import 'package:tdlogistic_v2/customer/data/models/calculate_fee_payload.dart';
import 'package:tdlogistic_v2/customer/data/models/shipping_bill.dart';
import 'package:tdlogistic_v2/customer/data/repositories/locations.dart';
import 'package:tdlogistic_v2/customer/data/repositories/voucher_repository.dart';
import 'order_event.dart';
import 'order_state.dart';
import '../../core/repositories/order_repository.dart';

class OrderBlocCus extends Bloc<OrderEvent, OrderState> {
  final SecureStorageService secureStorageService;
  final OrderRepository orderRepository = OrderRepository();

  OrderBlocCus({required this.secureStorageService}) : super(OrderLoading([])) {
    on<StartOrder>(getOrder);
  }

  Future<void> getOrder(StartOrder event, Emitter<OrderState> emit) async {
    emit(OrderLoading([]));

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

  OrderBlocSearchCus({required this.secureStorageService})
      : super(OrderLoading([])) {
    on<GetOrders>(getOrrder);
  }

  Future<void> getOrrder(event, emit) async {
    print("Getting order");
    if (event.status == 1) print("status = 1");
    emit(OrderLoading([]));
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
  final SecureStorageService secureStorageService;

  OrderBlocFee({required this.secureStorageService}) : super(OrderLoading([])) {
    on<CalculateFee>(calculateFee);
  }
  Future<void> calculateFee(event, emit) async {
    emit(OrderFeeCalculating()); // Trạng thái đang tính phí
    try {
      final token = await secureStorageService.getToken();
      final fee = await orderRepository.calculateFee(token!,CalculateFeePayLoad(
          serviceType: event.serviceType,
          cod: event.cod,
          latSource: event.latSource,
          longSource: event.longSource,
          latDestination: event.latDestination,
          longDestination: event.longDestination,
          voucherId: event.voucherId));

      print(fee);

      if (fee["success"]) {
        emit(OrderFeeCalculated(fee["data"]["value"])); // Thành công
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

  GetImagesBloc({required this.secureStorageService}) : super(GettingImages()) {
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
              sigImageIds[i]["id"], (await secureStorageService.getToken())!,
              isSign: true);
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

  ProcessingOrderBloc({required this.secureStorageService})
      : super(OrderLoading([])) {
    on<StartOrder>(getOrder);
    on<AddOrder>(addOrder);
  }

  Future<void> getOrder(event, emit) async {
    print("Getting order");
    emit(OrderLoading([]));
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
      emit(OrderLoading(currentState.orders));
      List<Order> updatedOrders = [];

      final fetchOrder = await orderRepository.getOrders(
        (await secureStorageService.getToken())!,
        status: "PROCESSING",
        page: event.page,
      );

      List<dynamic> fetchedOrders = fetchOrder["data"];
      if (fetchOrder["success"]) {
        for (int i = 0; i < fetchedOrders.length; i++) {
          updatedOrders.add(Order.fromJson(fetchedOrders[i]));
        }
      }
      emit(OrderLoaded(updatedOrders, updatedOrders.length, page: event.page));
    }
  }
}

class TakingOrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository = OrderRepository();
  final SecureStorageService secureStorageService;

  TakingOrderBloc({required this.secureStorageService})
      : super(OrderLoading([])) {
    on<StartOrder>(getOrder);
    on<AddOrder>(addOrder);
  }

  Future<void> getOrder(event, emit) async {
    print("Getting order");
    emit(OrderLoading([]));
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
      emit(OrderLoading(currentState.orders));
      List<Order> updatedOrders = [];

      final fetchOrder = await orderRepository.getOrders(
        (await secureStorageService.getToken())!,
        status: "TAKING",
        page: event.page,
      );

      List<dynamic> fetchedOrders = fetchOrder["data"];
      if (fetchOrder["success"]) {
        for (int i = 0; i < fetchedOrders.length; i++) {
          updatedOrders.add(Order.fromJson(fetchedOrders[i]));
        }
      }
      emit(OrderLoaded(updatedOrders, updatedOrders.length, page: event.page));
    }
  }
}

class DeliveringOrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository = OrderRepository();
  final SecureStorageService secureStorageService;

  DeliveringOrderBloc({required this.secureStorageService})
      : super(OrderLoading([])) {
    on<StartOrder>(getOrder);
    on<AddOrder>(addOrder);
  }

  Future<void> getOrder(event, emit) async {
    print("Getting order");
    emit(OrderLoading([]));
    try {
      final fetchOrder = await orderRepository.getOrders(
          (await secureStorageService.getToken())!,
          status: "DELIVERING");
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
      emit(OrderLoading(currentState.orders));
      List<Order> updatedOrders = [];

      final fetchOrder = await orderRepository.getOrders(
        (await secureStorageService.getToken())!,
        status: "DELIVERING",
        page: event.page,
      );

      List<dynamic> fetchedOrders = fetchOrder["data"];
      if (fetchOrder["success"]) {
        for (int i = 0; i < fetchedOrders.length; i++) {
          updatedOrders.add(Order.fromJson(fetchedOrders[i]));
        }
      }
      emit(OrderLoaded(updatedOrders, updatedOrders.length, page: event.page));
    }
  }
}

class CancelledOrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository = OrderRepository();
  final SecureStorageService secureStorageService;

  CancelledOrderBloc({required this.secureStorageService})
      : super(OrderLoading([])) {
    on<StartOrder>(getOrder);
    on<AddOrder>(addOrder);
  }

  Future<void> getOrder(event, emit) async {
    print("Getting order");
    emit(OrderLoading([]));
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
      emit(OrderLoading(currentState.orders));
      final List<Order> updatedOrders = [];

      final fetchOrder = await orderRepository.getOrders(
        (await secureStorageService.getToken())!,
        status: "CANCEL",
        page: event.page,
      );

      List<dynamic> fetchedOrders = fetchOrder["data"];
      if (fetchOrder["success"]) {
        for (int i = 0; i < fetchedOrders.length; i++) {
          updatedOrders.add(Order.fromJson(fetchedOrders[i]));
        }
      }
      emit(OrderLoaded(updatedOrders, updatedOrders.length, page: event.page));
    }
  }
}

class CompletedOrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository = OrderRepository();
  final SecureStorageService secureStorageService;

  CompletedOrderBloc({required this.secureStorageService})
      : super(OrderLoading([])) {
    on<StartOrder>(getOrder);
    on<AddOrder>(addOrder); // Thêm sự kiện mới cho việc thêm đơn hàng
  }

  Future<void> getOrder(event, emit) async {
    print("Getting order");
    emit(OrderLoading([]));
    try {
      final fetchOrder = await orderRepository.getOrders(
          (await secureStorageService.getToken())!,
          status: "RECEIVED");
      List<dynamic> fetchedOrders = fetchOrder["data"];
      List<Order> orders = [];
      if (fetchOrder["success"]) {
        for (int i = 0; i < fetchedOrders.length; i++) {
          orders.add(Order.fromJson(fetchedOrders[i]));
        }
      }
      emit(OrderLoaded(orders, orders.length));
    } catch (error) {
      print("Getting completed order: $error");
      emit(OrderError(error.toString()));
    }
  }

  void addOrder(AddOrder event, Emitter<OrderState> emit) async {
    if (state is OrderLoaded) {
      final currentState = state as OrderLoaded;
      emit(OrderLoading(currentState.orders));
      final List<Order> updatedOrders = [];

      final fetchOrder = await orderRepository.getOrders(
        (await secureStorageService.getToken())!,
        status: "RECEIVED",
        page: event.page,
      );

      List<dynamic> fetchedOrders = fetchOrder["data"];
      if (fetchOrder["success"]) {
        for (int i = 0; i < fetchedOrders.length; i++) {
          updatedOrders.add(Order.fromJson(fetchedOrders[i]));
        }
      }
      emit(OrderLoaded(updatedOrders, updatedOrders.length, page: event.page));
    }
  }
}

class CreateOrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository = OrderRepository();
  final SecureStorageService secureStorageService;

  CreateOrderBloc({required this.secureStorageService})
      : super(OrderLoading([])) {
    on<CreateOrderEvent>(createOrder);
    on<CreateShippingBill>(createShippingBill);
    on<GetShippingBill>(getShippingBill);
  }

  Future<void> createOrder(event, emit) async {
    emit(OrderCreating());
    try {
      print("debug");
      final tempDir = await getTemporaryDirectory();
      int i = 0;
      List<File> files = [];
      for (final image in event.files) {
        File file = await File('${tempDir.path}/file$i.png').create();
        file.writeAsBytesSync(image);
        files.add(file);
        i++;
      }
      late Map<String, dynamic> createShippingBill;
      if (event.sb != null) {
        createShippingBill = await orderRepository.createShippingBill(
            (await secureStorageService.getToken())!, event.sb);
        // print(createShippingBill);
        if (!createShippingBill["success"]) {
          emit(OrderCreateFaild(createShippingBill["message"]));
          return;
        }
        if (event.ci != null)
          event.ci.shippingBillId = createShippingBill["data"]["id"];
      }
      final orderCreate = await orderRepository.createOrder(
          (await secureStorageService.getToken())!,
          event.order,
          files,
          event.ci);
      if (orderCreate["success"]) {
        emit(OrderCreated());
      } else {
        emit(OrderCreateFaild(orderCreate["message"]));
      }
      await Future.delayed(const Duration(seconds: 4), () {
        emit(OrderLoading([]));
      });
    } catch (error) {
      print("Lỗi khi tạo đơn hàng $error");
      emit(OrderCreateFaild(error.toString()));
    }
  }

  Future<void> createShippingBill(event, emit) async {
    try {
      emit(OrderCreating());
      final createShippingBill = await orderRepository.createShippingBill(
          (await secureStorageService.getToken())!, event.sb);
      if (createShippingBill["success"]) {
        emit(CreatedShippingBill());
      } else {
        emit(FailedCreatingBill(createShippingBill["message"]));
      }
    } catch (error) {
      print("Lỗi khi tạo bảo hiểm đơn hàng: $error");
      emit(FailedCreatingBill(error.toString()));
    }
  }

  Future<void> getShippingBill(event, emit) async {
    try {
      emit(OrderCreating());
      final createShippingBill = await orderRepository
          .getShippingBill((await secureStorageService.getToken())!);
      if (createShippingBill["success"]) {
        emit(
            GotShippingBill(ShippingBill.fromJson(createShippingBill["data"])));
      } else {
        emit(FailedGettingBill(createShippingBill["message"]));
      }
    } catch (error) {
      print("Lỗi khi tạo bảo hiểm đơn hàng: $error");
      emit(FailedCreatingBill(error.toString()));
    }
  }
}

class GetLocationBloc extends Bloc<OrderEvent, OrderState> {
  final SecureStorageService secureStorageService;
  final LocationRepository locationRepository = LocationRepository();

  GetLocationBloc({required this.secureStorageService})
      : super(GettingLocations()) {
    on<GetLocations>(getLocations);
    on<AddLocation>(addLocation);
    on<UpdateLocation>(updateLocation);
    on<UpdateFavoriteLocation>(updateFavoriteLocations);
    on<DeleteLocation>(deleteLocation);
  }

  Future<void> getLocations(event, emit) async {
    emit(GettingLocations());
    try {
      final getLocations = await locationRepository
          .getLocations((await secureStorageService.getToken())!);
      if (getLocations["success"]) {
        emit(GotLocations(
            favLocations: getLocations["data"][1],
            locations: getLocations["data"][0]));
      } else {
        emit(FailGettingLocations(getLocations["message"]));
      }
    } catch (error) {
      print("Lỗi khi lấy địa điểm $error");
      emit(FailGettingLocations(error.toString()));
    }
  }

  Future<void> addLocation(event, emit) async {
    try {
      if (event.loc != null) {
        await locationRepository.createLocations(
            (await secureStorageService.getToken())!,
            event.loc.name,
            event.loc.lat,
            event.loc.lng);
      } else {
        await locationRepository.createFavLocations(
            (await secureStorageService.getToken())!,
            event.faLoc.description,
            event.faLoc.name,
            event.faLoc.phoneNumber,
            event.faLoc.lat,
            event.faLoc.lng);
      }
      await getLocations(event, emit);
    } catch (error) {
      print("Error adding location or favorite location: ${error.toString()}");
    }
  }

  Future<void> updateLocation(event, emit) async {
    try {
      await locationRepository.updateLocation(
          (await secureStorageService.getToken())!, event.loc);
      await getLocations(event, emit);
    } catch (error) {
      print("Lỗi khi cập nhật địa điểm $error");
    }
  }

  Future<void> updateFavoriteLocations(event, emit) async {
    try {
      await locationRepository.updateFavoriteLocation(
          (await secureStorageService.getToken())!, event.favLoc);
      await getLocations(event, emit);
    } catch (error) {
      print("Lỗi khi cập nhật địa điểm ưa thích $error");
    }
  }

  Future<void> deleteLocation(event, emit) async {
    try {
      await locationRepository.deleteLocation(
          (await secureStorageService.getToken())!, event.locationId,
          isFav: event.isFav);
      await getLocations(event, emit);
    } catch (error) {
      print("Lỗi khi xoá địa điểm: $error");
    }
  }
}

class GetPositionsBloc extends Bloc<OrderEvent, OrderState> {
  final LocationRepository locationRepository = LocationRepository();
  final SecureStorageService secureStorageService;

  GetPositionsBloc({required this.secureStorageService})
      : super(GettingPositions()) {
    on<GetPositions>(getPos);
  }

  Future<void> getPos(event, emit) async {
    emit(GettingPositions());
    try {
      final getPos = await locationRepository.getPositions(
          (await secureStorageService.getToken())!, event.orderId);
      print(getPos);
      if (getPos["success"]) {
        emit(GotPositions(getPos["data"]));
      } else {
        emit(FailedGetPositions(getPos["message"]));
      }
    } catch (error) {
      emit(FailedGetPositions(error.toString()));
    }
  }
}

class GetChatsBloc extends Bloc<OrderEvent, OrderState> {
  final SecureStorageService secureStorageService;
  final ChatRepository chatRepository = ChatRepository();

  GetChatsBloc({required this.secureStorageService})
      : super(GettingPositions()) {
    on<GetChats>(_getChats);
  }

  Future<void> _getChats(GetChats event, Emitter<OrderState> emit) async {
    emit(GettingPositions());
    try {
      final token = (await secureStorageService.getToken())!;
      final result =
          await chatRepository.getReceivers(token, event.page, event.size);

      if (result['success']) {
        emit(GetChatsSuccess(result['data']));
      } else {
        emit(GetChatsFailure(result['message']));
      }
    } catch (error) {
      emit(GetChatsFailure('Có lỗi xảy ra: ${error.toString()}'));
    }
  }
}

class GetChatBloc extends Bloc<OrderEvent, OrderState> {
  final SecureStorageService secureStorageService;
  final ChatRepository chatRepository = ChatRepository();

  GetChatBloc({required this.secureStorageService})
      : super(GettingPositions()) {
    on<GetChatWithShip>(_getChatWithCus);
    on<NewMessage>(addMessage);
  }

  Future<void> _getChatWithCus(
      GetChatWithShip event, Emitter<OrderState> emit) async {
    emit(GettingPositions());
    try {
      final token = (await secureStorageService.getToken())!;
      final result = await chatRepository.getMessages(
          token, event.receiverId, event.page, event.size);

      if (result['success']) {
        emit(GetChatWithShipSuccess(result['data']));
      } else {
        emit(GetChatWithShipFailure(result['message']));
      }
    } catch (error) {
      emit(GetChatWithShipFailure('Có lỗi xảy ra: ${error.toString()}'));
    }
  }

  Future<void> addMessage(event, emit) async {
    try {
      emit(ReceiveMessage({'content': event.newMess, 'receiverId': " "}));
    } catch (error) {
      emit(GetChatWithShipFailure('Có lỗi xảy ra: ${error.toString()}'));
    }
  }
}

class GetIdBloc extends Bloc<OrderEvent, OrderState> {
  final SecureStorageService secureStorageService;
  final OrderRepository orderRepository = OrderRepository();

  GetIdBloc({required this.secureStorageService}) : super(GettingPositions()) {
    on<GetId>(_getIdFromOrder);
  }

  Future<void> _getIdFromOrder(event, emit) async {
    emit(GettingPositions());
    try {
      final token = (await secureStorageService.getToken())!;
      final result = await orderRepository.getShipperOrders(token, event.id);

      if (result['success']) {
        emit(GotId(result['data']));
      } else {
        emit(GetChatWithShipFailure(result['message']));
      }
    } catch (error) {
      emit(GetChatWithShipFailure('Có lỗi xảy ra: ${error.toString()}'));
    }
  }
}

class GetVoucherBloc extends Bloc<OrderEvent, OrderState> {
  final SecureStorageService secureStorageService;
  final VoucherRepository voucherRepository = VoucherRepository();

  GetVoucherBloc({required this.secureStorageService})
      : super(GettingPositions()) {
    on<GetVouchers>(_getVouchers);
  }

  Future<void> _getVouchers(event, emit) async {
    emit(GettingPositions());
    try {
      final token = (await secureStorageService.getToken())!;
      final result =
          await voucherRepository.getVouchers(token, event.page, event.size);

      if (result['success']) {
        emit(GotVouchers(result['data']));
      } else {
        emit(GetChatWithShipFailure(result['message']));
      }
    } catch (error) {
      emit(GetChatWithShipFailure('Có lỗi xảy ra: ${error.toString()}'));
    }
  }
}
