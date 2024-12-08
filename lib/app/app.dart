import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdlogistic_v2/auth/UI/screens/OTP_verification.dart';
import 'package:tdlogistic_v2/auth/UI/screens/ask_name.dart';
import 'package:tdlogistic_v2/auth/UI/screens/customer_login_page.dart';
import 'package:tdlogistic_v2/auth/UI/screens/home_page.dart';
import 'package:tdlogistic_v2/auth/UI/screens/shipper_login_page.dart';
import 'package:tdlogistic_v2/auth/UI/screens/splash_screen.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_event.dart';
import 'package:tdlogistic_v2/auth/bloc/auth_state.dart';
import 'package:tdlogistic_v2/auth/data/models/user_model.dart';
import 'package:tdlogistic_v2/core/service/secure_storage_service.dart';
import 'package:tdlogistic_v2/core/service/send_location.dart';
import 'package:tdlogistic_v2/core/service/socket_for_customer.dart';
import 'package:tdlogistic_v2/core/service/socket_for_shipper.dart';
import 'package:tdlogistic_v2/customer/UI/screens/botton_navigator.dart';
import 'package:tdlogistic_v2/customer/bloc/order_bloc.dart';
import 'package:tdlogistic_v2/customer/bloc/order_event.dart';
import 'package:tdlogistic_v2/shipper/bloc/task_bloc.dart';
import 'package:tdlogistic_v2/shipper/bloc/task_event.dart';
import '../auth/bloc/auth_bloc.dart';
import 'app_bloc.dart';

class MyApp extends StatefulWidget {
  final SecureStorageService secureStorageService;
  final LocationTrackerService locationTrackerService;
  const MyApp({
    super.key,
    required this.secureStorageService,
    required this.locationTrackerService,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    bool hasCustomerRole(User user) {
      // Kiểm tra nếu roles không null và chứa giá trị 'CUSTOMER'
      return user.roles == null;
      //  && user.roles!.any((role) => role.value == 'CUSTOMER');
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthBloc()..add(StartApp()),
        ),
        BlocProvider(
          create: (context) => AppBloc(),
        ),
        BlocProvider<OrderBlocCus>(
          create: (context) => OrderBlocCus(
            secureStorageService: widget.secureStorageService,
          )..add(StartOrder()),
        ),
        BlocProvider<UserBloc>(
          create: (context) => UserBloc(
            secureStorageService: widget.secureStorageService,
          ),
        ),
        BlocProvider<OrderBlocSearchCus>(
          create: (context) => OrderBlocSearchCus(
            secureStorageService: widget.secureStorageService,
          )..add(const GetOrders()),
        ),
        BlocProvider<OrderBlocFee>(
          create: (context) => OrderBlocFee(
            secureStorageService: widget.secureStorageService,
          ),
        ),
        BlocProvider<TaskBlocShipReceive>(
          create: (context) => TaskBlocShipReceive(
              secureStorageService: widget.secureStorageService),
        ),
        BlocProvider<TaskBlocShipSend>(
          create: (context) => TaskBlocShipSend(
              secureStorageService: widget.secureStorageService,
              locationTrackerService: widget.locationTrackerService),
        ),
        BlocProvider<TaskBlocSearchShip>(
          create: (context) => TaskBlocSearchShip(
              secureStorageService: widget.secureStorageService),
        ),
        BlocProvider<ProcessingOrderBloc>(
          create: (context) => ProcessingOrderBloc(
            secureStorageService: widget.secureStorageService,
          )..add(StartOrder()),
        ),
        BlocProvider<TakingOrderBloc>(
          create: (context) => TakingOrderBloc(
            secureStorageService: widget.secureStorageService,
          )..add(StartOrder()),
        ),
        BlocProvider<DeliveringOrderBloc>(
          create: (context) => DeliveringOrderBloc(
            secureStorageService: widget.secureStorageService,
          )..add(StartOrder()),
        ),
        BlocProvider<CancelledOrderBloc>(
          create: (context) => CancelledOrderBloc(
            secureStorageService: widget.secureStorageService,
          )..add(StartOrder()),
        ),
        BlocProvider<PendingOrderBloc>(
          create: (context) => PendingOrderBloc(
            secureStorageService: widget.secureStorageService,
          )..add(GetPendingTask()),
        ),
        BlocProvider<CompletedOrderBloc>(
          create: (context) => CompletedOrderBloc(
            secureStorageService: widget.secureStorageService,
          )..add(StartOrder()),
        ),
        BlocProvider<GetImagesBloc>(
          create: (context) => GetImagesBloc(
            secureStorageService: widget.secureStorageService,
          ),
        ),
        BlocProvider<GetImagesShipBloc>(
          create: (context) => GetImagesShipBloc(
            secureStorageService: widget.secureStorageService,
          ),
        ),
        BlocProvider<UpdateImagesShipBloc>(
          create: (context) => UpdateImagesShipBloc(
            secureStorageService: widget.secureStorageService,
          ),
        ),
        BlocProvider<AcceptTask>(
          create: (context) => AcceptTask(
            secureStorageService: widget.secureStorageService,
          ),
        ),
        BlocProvider<CreateOrderBloc>(
          create: (context) => CreateOrderBloc(
            secureStorageService: widget.secureStorageService,
          ),
        ),
        BlocProvider<GetLocationBloc>(
          create: (context) => GetLocationBloc(
            secureStorageService: widget.secureStorageService,
          ),
        ),
        BlocProvider<GetPositionsBloc>(
          create: (context) => GetPositionsBloc(
            secureStorageService: widget.secureStorageService,
          ),
        ),
        BlocProvider<ConfirmTaskBloc>(
          create: (context) => ConfirmTaskBloc(
            secureStorageService: widget.secureStorageService,
          ),
        ),
        BlocProvider<GetChatsBloc>(
          create: (context) => GetChatsBloc(
            secureStorageService: widget.secureStorageService,
          ),
        ),
        BlocProvider<GetChatBloc>(
          create: (context) => GetChatBloc(
            secureStorageService: widget.secureStorageService,
          ),
        ),
        BlocProvider<GetChatsShipBloc>(
          create: (context) => GetChatsShipBloc(
            secureStorageService: widget.secureStorageService,
          ),
        ),
        BlocProvider<GetChatShipBloc>(
          create: (context) => GetChatShipBloc(
            secureStorageService: widget.secureStorageService,
          ),
        ),
        BlocProvider<GetIdBloc>(
          create: (context) => GetIdBloc(
            secureStorageService: widget.secureStorageService,
          ),
        ),
        BlocProvider<GetVoucherBloc>(
          create: (context) => GetVoucherBloc(
            secureStorageService: widget.secureStorageService,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My Flutter App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              if (state.user == null) {
                // return const HomePage(); // test mạng
                return SocketCustomerPage(user: User(id: "123"), token: " ");
              }
              if (hasCustomerRole(state.user!)) {
                void setName(String fName, String lName) {
                  setState(() {
                    state.user!.lastName = lName;
                    state.user!.firstName = fName;
                  });
                }

                if (state.user!.lastName == null) {
                  return NameInputScreen(
                    getName: setName,
                  );
                } else {
                  return SocketCustomerPage(
                      user: state.user!, token: state.token);
                }
              } else {
                return SocketPage(user: state.user!, token: state.token);
              }
            } else if (state is SentOtp) {
              return OtpVerificationPage(
                  email: state.email,
                  phone: state.phone,
                  msg: state.msg,
                  id: state.id);
            } else if (state is AuthFailure) {
              return state.isStaff
                  ? StaffLoginPage(
                      msg: state.error,
                      username: state.email,
                      password: state.phone)
                  : CustomerLoginPage(
                      msg: state.error, email: state.email, phone: state.phone);
            } else if (state is Unauthenticated) {
              // return SocketPage(user: User());

              return state.isStaff
                  ? const StaffLoginPage(msg: "", username: "", password: "")
                  : CustomerLoginPage(
                      msg: "", email: state.email, phone: state.phone);
            } else {
              return const SplashScreen(); // Hiển thị màn hình chờ
            }
          },
        ),
      ),
    );
  }
}
