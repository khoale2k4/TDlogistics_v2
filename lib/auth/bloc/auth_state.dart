import 'package:tdlogistic_v2/auth/data/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class Authenticated extends AuthState {
  final User? user;
  final String token;

  Authenticated(this.user, this.token);
}

class Unauthenticated extends AuthState {
  final String email;
  final String phone;
  final String msg;
  final bool isStaff;

  Unauthenticated(this.email, this.phone, this.msg, this.isStaff);
}

class SendingOtp extends AuthState {}

class SentOtp extends AuthState {
  final String email;
  final String phone;
  final String msg;
  final String id;

  SentOtp(this.email, this.phone, this.msg, this.id);
}

class VerifyingOtp extends AuthState {}

class AuthFailure extends AuthState {
  final String error;
  final String email;
  final String phone;
  final bool isStaff;

  AuthFailure(this.error, this.email, this.phone, this.isStaff);
}

class StaffLoggining extends AuthState {}

class UpdatedInfo extends AuthState{}

class FailedUpdateInfo extends AuthState{
  final String error;

  FailedUpdateInfo({required this.error});
}

class UpdatingInfo extends AuthState{}
