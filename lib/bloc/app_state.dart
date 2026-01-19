import 'package:equatable/equatable.dart';

enum AppStatus { idle, loading, success, error }

class AppState extends Equatable {
  final AppStatus status;
  final String message;

  const AppState({this.status = AppStatus.idle, this.message = ''});

  AppState copyWith({AppStatus? status, String? message}) {
    return AppState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, message];
}
