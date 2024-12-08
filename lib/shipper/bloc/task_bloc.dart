import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlogistic_v2/core/models/chats_model.dart';
import 'package:tdlogistic_v2/core/models/order_model.dart';
import 'package:tdlogistic_v2/core/repositories/chat_repository.dart';
import 'package:tdlogistic_v2/core/repositories/order_repository.dart';
import 'package:tdlogistic_v2/core/service/secure_storage_service.dart';
import 'package:tdlogistic_v2/core/service/send_location.dart';
import 'package:tdlogistic_v2/shipper/data/models/task.dart';
import 'package:tdlogistic_v2/shipper/data/repositories/task_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBlocShipReceive extends Bloc<TaskEvent, TaskState> {
  final OrderRepository orderRepository = OrderRepository();
  final SecureStorageService secureStorageService;
  final TaskRepository taskRepository = TaskRepository();

  TaskBlocShipReceive({required this.secureStorageService})
      : super(TaskLoading()) {
    on<StartTask>(getTask);
    on<AddTask>(addTask);
  }

  Future<void> getTask(StartTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());

    try {
      final fetchTask = await taskRepository.getTasks(
          (await secureStorageService.getToken())!, "TAKING");
      List<dynamic> fetchedTasks = [];
      List<Task> tasks = [];
      if (fetchTask["success"]) {
        fetchedTasks = fetchTask["data"];
        for (int i = 0; i < fetchedTasks.length; i++) {
          Task newTask = Task.fromJson(fetchedTasks[i]);
          final order = await orderRepository.getOrderById(
              newTask.order!.id!, (await secureStorageService.getToken())!);
          if (order["success"] && order["data"].length > 0) {
            newTask.order = Order.fromJson(order["data"].first);
            tasks.add(newTask);
          }
        }
      }
      emit(TaskLoaded(tasks, tasks.length));
    } catch (error) {
      emit(TaskError("Lỗi khi lấy task: $error"));
    }
  }

  void addTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      if (state is TaskLoaded) {
        final currentState = state as TaskLoaded;
        emit(TaskLoading());
        final List<Task> updatedTasks = [];

        final fetchTask = await taskRepository.getTasks(
          (await secureStorageService.getToken())!,
          "TAKING",
          page: event.page,
        );

        List<dynamic> fetchedTasks = fetchTask["data"];
        if (fetchTask["success"]) {
          if (fetchedTasks.length == 0) {
            emit(TaskLoaded(updatedTasks, updatedTasks.length,
                page: currentState.page));
            return;
          }
          for (int i = 0; i < fetchedTasks.length; i++) {
            Task newTask = Task.fromJson(fetchedTasks[i]);
            final order = await orderRepository.getOrderById(
                newTask.order!.id!, (await secureStorageService.getToken())!);
            if (order["success"] && order["data"].length > 0) {
              newTask.order = Order.fromJson(order["data"].first);
              updatedTasks.add(newTask);
            } else {
              updatedTasks.add(Task.fromJson(fetchedTasks[i]));
            }
          }
          emit(TaskLoaded(updatedTasks, updatedTasks.length, page: event.page));
        }
        emit(TaskLoaded(updatedTasks, updatedTasks.length,
            page: currentState.page));
      }
    } catch (error) {
      print("error adding tasks: ${error.toString()}");
      emit(TaskLoaded(const [], 0, page: 1));
    }
  }
}

class TaskBlocShipSend extends Bloc<TaskEvent, TaskState> {
  final OrderRepository orderRepository = OrderRepository();
  final SecureStorageService secureStorageService;
  final TaskRepository taskRepository = TaskRepository();
  final LocationTrackerService locationTrackerService;

  TaskBlocShipSend(
      {required this.secureStorageService,
      required this.locationTrackerService})
      : super(TaskLoading()) {
    on<StartTask>(getTask);
    on<AddTask>(addTask);
  }

  Future<void> getTask(StartTask event, Emitter<TaskState> emit) async {
    emit(TaskLoading());

    try {
      final fetchTask = await taskRepository.getTasks(
          (await secureStorageService.getToken())!, 'DELIVERING');
      List<dynamic> fetchedTasks = [];
      List<Task> tasks = [];
      if (fetchTask["success"]) {
        fetchedTasks = fetchTask["data"];
        for (int i = 0; i < fetchedTasks.length; i++) {
          Task newTask = Task.fromJson(fetchedTasks[i]);
          final order = await orderRepository.getOrderById(
              newTask.order!.id!, (await secureStorageService.getToken())!);
          if (order["success"] && order["data"].length > 0) {
            newTask.order = Order.fromJson(order["data"].first);
            tasks.add(newTask);
          }
        }
        List<String> taskIds = tasks.map((task) => task.id!).toList();
        locationTrackerService.changeToThisList(taskIds);
        locationTrackerService
            .startLocationTracking((await secureStorageService.getToken())!);
      }
      emit(TaskLoaded(tasks, tasks.length));
    } catch (error) {
      emit(TaskError("Lỗi khi lấy task: $error"));
    }
  }

  void addTask(AddTask event, Emitter<TaskState> emit) async {
    if (state is TaskLoaded) {
      final currentState = state as TaskLoaded;
      emit(TaskLoading());
      final List<Task> updatedTasks = [];

      final fetchTask = await taskRepository.getTasks(
        (await secureStorageService.getToken())!,
        'DELIVERING',
        page: event.page,
      );

      List<dynamic> fetchedTasks = fetchTask["data"];
      if (fetchTask["success"]) {
        if (fetchedTasks.length == 0) {
          emit(TaskLoaded(updatedTasks, updatedTasks.length,
              page: currentState.page));
          return;
        }
        for (int i = 0; i < fetchedTasks.length; i++) {
          Task newTask = Task.fromJson(fetchedTasks[i]);
          final order = await orderRepository.getOrderById(
              newTask.order!.id!, (await secureStorageService.getToken())!);
          if (order["success"] && order["data"].length > 0) {
            newTask.order = Order.fromJson(order["data"].first);
            updatedTasks.add(newTask);
          } else {
            updatedTasks.add(Task.fromJson(fetchedTasks[i]));
          }
        }
        emit(TaskLoaded(updatedTasks, updatedTasks.length, page: event.page));
      }
      emit(TaskLoaded(updatedTasks, updatedTasks.length,
          page: currentState.page));
    }
  }
}

class TaskBlocSearchShip extends Bloc<TaskEvent, TaskState> {
  final OrderRepository orderRepository = OrderRepository();
  final SecureStorageService secureStorageService;
  final TaskRepository taskRepository = TaskRepository();

  TaskBlocSearchShip({
    required this.secureStorageService,
  }) : super(TaskLoading()) {
    on<GetTasks>(getOrder);
    on<AddTask>(addTask);
  }

  Future<void> getOrder(event, emit) async {
    emit(TaskLoading());
    try {
      final fetchTask = await taskRepository.getTasks(
          (await secureStorageService.getToken())!, "");
      List<dynamic> fetchedTasks = fetchTask["data"];
      List<Task> tasks = [];
      if (fetchTask["success"]) {
        fetchedTasks = fetchTask["data"];
        for (int i = 0; i < fetchedTasks.length; i++) {
          Task newTask = Task.fromJson(fetchedTasks[i]);
          final order = await orderRepository.getOrderById(
              fetchedTasks[i]["orderId"],
              (await secureStorageService.getToken())!);
          if (order["success"] && order["data"].length > 0) {
            newTask.order = Order.fromJson(order["data"].first);
            tasks.add(newTask);
          }
        }
      }
      emit(TaskLoaded(tasks, tasks.length));
    } catch (error) {
      print("Lỗi khi lấy task history: $error");
      emit(TaskError(error.toString()));
    }
  }

  void addTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      if (state is TaskLoaded) {
        final currentState = state as TaskLoaded;
        emit(TaskLoading());
        final updatedTasks = List<Task>.from(currentState.tasks);
        final newPage = currentState.page + 1;

        final fetchTask = await taskRepository.getTasks(
          (await secureStorageService.getToken())!,
          "",
          page: newPage,
        );

        List<dynamic> fetchedTasks = fetchTask["data"];
        if (fetchTask["success"]) {
          for (int i = 0; i < fetchedTasks.length; i++) {
            Task newTask = Task.fromJson(fetchedTasks[i]);
            final order = await orderRepository.getOrderById(
                newTask.order!.id!, (await secureStorageService.getToken())!);
            if (order["success"] && order["data"].length > 0) {
              newTask.order = Order.fromJson(order["data"].first);
              updatedTasks.add(newTask);
            } else {
              updatedTasks.add(Task.fromJson(fetchedTasks[i]));
            }
          }
        }
        emit(TaskLoaded(updatedTasks, updatedTasks.length, page: newPage));
      }
    } catch (error) {
      print("Error adding task $error");
      emit(FailedImage(error.toString()));
    }
  }
}

class GetImagesShipBloc extends Bloc<TaskEvent, TaskState> {
  final OrderRepository orderRepository = OrderRepository();
  final SecureStorageService secureStorageService;

  GetImagesShipBloc({required this.secureStorageService})
      : super(GettingImages()) {
    on<GetOrderImages>(getImages);
  }

  Future<void> getImages(event, emit) async {
    emit(GettingImages());

    try {
      final order = await orderRepository.getOrderById(
          event.orderId, (await secureStorageService.getToken())!);
      if (order["success"]) {
        print(event.orderId);
        List<Uint8List> send = [];
        List<String> sendIds = [];
        List<Uint8List> receive = [];
        List<String> receiveIds = [];
        Uint8List? sendSig;
        String sendSigId = "";
        Uint8List? receiveSig;
        String receiveSigId = "";
        final imageIds = order["data"][0]["images"];
        for (int i = 0; i < imageIds.length; i++) {
          bool isSend = (imageIds[i]["type"] == "SEND");
          final imageRs = await orderRepository.getOrderImageById(
              imageIds[i]["id"], (await secureStorageService.getToken())!);
          if (isSend) {
            sendIds.add(imageIds[i]["id"]);
            send.add(imageRs["data"]);
          } else {
            receiveIds.add(imageIds[i]["id"]);
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
            sendSigId = sigImageIds[i]["id"];
            sendSig = imageRs["data"];
          } else {
            receiveSigId = sigImageIds[i]["id"];
            receiveSig = imageRs["data"];
          }
        }
        emit(GotImages(receive, receiveIds, receiveSig, receiveSigId, send,
            sendIds, sendSig, sendSigId));
      } else {
        emit(GotImages(
            const [], const [], null, "", const [], const [], null, ""));
      }
    } catch (error) {
      print("Error getting images: ${error.toString()}");
      emit(GotImages(
          const [], const [], null, "", const [], const [], null, ""));
    }
  }
}

class UpdateImagesShipBloc extends Bloc<TaskEvent, TaskState> {
  final OrderRepository orderRepository = OrderRepository();
  final SecureStorageService secureStorageService;

  UpdateImagesShipBloc({required this.secureStorageService})
      : super(AddedImage()) {
    on<AddImageEvent>(updateImages);
    on<DeleteImage>(deleteImage);
  }

  Future<void> updateImages(event, emit) async {
    emit(AddingImage());
    try {
      final tempDir = await getTemporaryDirectory();
      List<File> files = [];
      for (int i = 0; i < event.curImages.length; i++) {
        File file = await File('${tempDir.path}/image_$i.png').create();
        file.writeAsBytesSync(event.curImages[i]);
        files.add(file);
      }
      if (event.newImage != null) {
        File file =
            await File('${tempDir.path}/image_${event.curImages.length}.png')
                .create();
        file.writeAsBytesSync(event.newImage);
        files.add(file);
      }
      final upImageRs = await orderRepository.updateImage(event.orderId, files,
          event.category, (await secureStorageService.getToken())!,
          isSign: event.isSign);
      if (upImageRs["success"]) {
        emit(AddedImage());
      } else {
        print("Lỗi khi lấy hình: " + upImageRs['message']);
        emit(FailedImage(upImageRs['message']));
      }
    } catch (error) {
      emit(FailedImage(error.toString()));
    }
  }

  Future<void> deleteImage(event, emit) async {
    emit(AddingImage());
    try {
      print("Delete image" + event.id);
      final deleteImage = await orderRepository.deleteFile(
          event.id, (await secureStorageService.getToken())!,
          isSign: true);
      print(deleteImage);
      if (deleteImage["success"]) {
        emit(AddedImage());
      } else {
        emit(FailedImage(deleteImage['message']));
      }
    } catch (error) {
      emit(FailedImage(error.toString()));
    }
  }
}

class AcceptTask extends Bloc<TaskEvent, TaskState> {
  final OrderRepository orderRepository = OrderRepository();
  final SecureStorageService secureStorageService;
  final TaskRepository taskRepository = TaskRepository();

  AcceptTask({
    required this.secureStorageService,
  }) : super(WaitingTask()) {
    on<AcceptTaskEvent>(acceptTask);
  }
  Future<void> acceptTask(event, emit) async {
    emit(AcceptingTask());
    try {
      final acceptTask = await taskRepository.acceptTasks(
          (await secureStorageService.getToken())!, event.orderId);

      print(acceptTask);

      if (acceptTask["success"]) {
        emit(AcceptedTask());
      } else {
        emit(FailedAcceptingTask(acceptTask["message"]));
      }
    } catch (error) {
      emit(FailedAcceptingTask(error.toString()));
    }
  }
}

class PendingOrderBloc extends Bloc<TaskEvent, TaskState> {
  final SecureStorageService secureStorageService;

  PendingOrderBloc({required this.secureStorageService})
      : super(TaskLoading()) {
    on<GetPendingTask>(getPendingTask);
    on<AddTask>(addTask);
    on<AcceptTaskEvent>(acceptTask);
  }

  Future<void> getPendingTask(event, emit) async {
    emit(TaskLoading());
    try {
      OrderRepository orderRepository = OrderRepository();

      final pendingOrders = await orderRepository.getOrders(
          (await secureStorageService.getToken())!,
          status: "PROCESSING");
      List<Task> tasks = [];

      if (pendingOrders["success"]) {
        final fetchedTasks = pendingOrders["data"];
        for (int i = 0; i < fetchedTasks.length; i++) {
          Task newTask = Task.fromJson(fetchedTasks[i]);
          final order = await orderRepository.getOrderById(
              newTask.id!, (await secureStorageService.getToken())!);
          if (order["success"] && order["data"].length > 0) {
            newTask.order = Order.fromJson(order["data"].first);
            tasks.add(newTask);
          }
        }
      }
      emit(TaskLoaded(tasks, tasks.length));
    } catch (error) {
      emit(TaskError("Lỗi khi lấy task: $error"));
    }
  }

  Future<void> acceptTask(event, emit) async {
    emit(TaskLoading());
    try {
      // Khởi tạo các repository
      OrderRepository orderRepository = OrderRepository();
      TaskRepository taskRepository = TaskRepository();

      // Chấp nhận nhiệm vụ
      final acceptTask = await taskRepository.acceptTasks(
        (await secureStorageService.getToken())!,
        event.orderId,
      );

      // Kiểm tra kết quả chấp nhận nhiệm vụ
      if (acceptTask["success"]) {
        emit(AcceptedTask());
      } else {
        emit(FailedAcceptingTask(acceptTask["message"]));
      }

      // Lấy danh sách đơn hàng đang xử lý
      final pendingOrders = await orderRepository.getOrders(
        (await secureStorageService.getToken())!,
        status: "PROCESSING",
      );

      List<Task> tasks = [];

      // Kiểm tra và xử lý các đơn hàng được tải
      if (pendingOrders["success"]) {
        final fetchedTasks = pendingOrders["data"];
        for (var fetchedTask in fetchedTasks) {
          Task newTask = Task.fromJson(fetchedTask);
          final order = await orderRepository.getOrderById(
            newTask.id!,
            (await secureStorageService.getToken())!,
          );

          // Thêm thông tin đơn hàng vào nhiệm vụ nếu tải thành công
          if (order["success"] && order["data"].isNotEmpty) {
            newTask.order = Order.fromJson(order["data"].first);
            tasks.add(newTask);
          }
        }
      }

      // Phát trạng thái hoàn thành với danh sách nhiệm vụ
      emit(TaskLoaded(tasks, tasks.length));
    } catch (error) {
      emit(TaskError("Lỗi khi lấy task: $error"));
    }
  }

  void addTask(AddTask event, Emitter<TaskState> emit) async {
    try {
      if (state is TaskLoaded) {
        OrderRepository orderRepository = OrderRepository();
        emit(TaskLoading());
        final List<Task> updatedTasks = [];

        final fetchTask = await orderRepository.getOrders(
            (await secureStorageService.getToken())!,
            status: "PROCESSING",
            page: event.page);
        List<dynamic> fetchedTasks = fetchTask["data"];
        if (fetchTask["success"]) {
          for (int i = 0; i < fetchedTasks.length; i++) {
            Task newTask = Task.fromJson(fetchedTasks[i]);
            final order = await orderRepository.getOrderById(
                newTask.id!, (await secureStorageService.getToken())!);
            if (order["success"] && order["data"].length > 0) {
              newTask.order = Order.fromJson(order["data"].first);
              updatedTasks.add(newTask);
            } else {
              updatedTasks.add(Task.fromJson(fetchedTasks[i]));
            }
          }
        }
        emit(TaskLoaded(updatedTasks, updatedTasks.length, page: event.page));
      }
    } catch (error) {
      print("error adding tasks: ${error.toString()}");
      emit(TaskLoaded(const [], 0, page: 1));
    }
  }
}

class ConfirmTaskBloc extends Bloc<TaskEvent, TaskState> {
  final SecureStorageService secureStorageService;
  final TaskRepository taskRepository = TaskRepository();

  ConfirmTaskBloc({required this.secureStorageService})
      : super(AcceptingTask()) {
    on<ConfirmTask>(confirmTask);
  }

  Future<void> confirmTask(event, emit) async {
    try {
      emit(AcceptingTask());

      var rs;
      if (event.type == "confirm taken") {
        rs = await taskRepository.confirmTakenTasks(
            (await secureStorageService.getToken())!, event.taskId);
      } else if (event.type == "confirm delivering") {
        rs = await taskRepository.confirmDeliverTasks(
            (await secureStorageService.getToken())!, event.taskId);
      } else if (event.type == "confirm completed") {
        rs = await taskRepository.confirmReceivedTasks(
            (await secureStorageService.getToken())!, event.taskId);
      } else {
        rs = await taskRepository.cancelTasks(
            (await secureStorageService.getToken())!,
            event.taskId,
            event.reason);
      }
      if (rs["success"]) {
        emit(FailedAcceptingTask(rs["message"]));
      } else {
        emit(AcceptedTask());
      }
    } catch (error) {
      print("error confirming task: $error");
      emit(FailedAcceptingTask(error.toString()));
    }
  }
}

class GetChatsShipBloc extends Bloc<TaskEvent, TaskState> {
  final SecureStorageService secureStorageService;
  final ChatRepository chatRepository = ChatRepository();

  GetChatsShipBloc({required this.secureStorageService})
      : super(TaskFeeCalculating()) {
    on<GetChats>(_getChats);
  }

  Future<void> _getChats(GetChats event, Emitter<TaskState> emit) async {
    emit(TaskFeeCalculating());
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

class GetChatShipBloc extends Bloc<TaskEvent, TaskState> {
  final SecureStorageService secureStorageService;
  final ChatRepository chatRepository = ChatRepository();

  GetChatShipBloc({required this.secureStorageService})
      : super(TaskFeeCalculating()) {
    on<GetChatWithCus>(_getChatWithCus);
    on<NewMessage>(addMessage);
  }

  Future<void> _getChatWithCus(
      GetChatWithCus event, Emitter<TaskState> emit) async {
    emit(TaskFeeCalculating());
    try {
      final token = (await secureStorageService.getToken())!;
      final result = await chatRepository.getMessages(
          token, event.receiverId, event.page, event.size);

      if (result['success']) {
        emit(GetChatWithCusSuccess(result['data']));
      } else {
        emit(GetChatWithCusFailure(result['message']));
      }
    } catch (error) {
      emit(GetChatWithCusFailure('Có lỗi xảy ra: ${error.toString()}'));
    }
  }

  Future<void> addMessage(event, emit) async {
    try {
      emit(ReceiveMessage({'content': event.newMess, 'receiverId': " "}));
    } catch (error) {
      emit(GetChatWithCusFailure('Có lỗi xảy ra: ${error.toString()}'));
    }
  }
}
