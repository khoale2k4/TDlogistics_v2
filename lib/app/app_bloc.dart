import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AppEvent {}

class ThemeChanged extends AppEvent {
  final bool isDarkMode;

  ThemeChanged({required this.isDarkMode});
}

abstract class AppState {}

class AppInitial extends AppState {}

class AppThemeState extends AppState {
  final bool isDarkMode;

  AppThemeState({required this.isDarkMode});
}

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(AppInitial()) {
    on<ThemeChanged>((event, emit) {
      emit(AppThemeState(isDarkMode: event.isDarkMode));
    });
  }
}
