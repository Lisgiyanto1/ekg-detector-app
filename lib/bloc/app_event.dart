import 'package:equatable/equatable.dart';

abstract class AppEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitializeApp extends AppEvent {}

class UpdateMessage extends AppEvent {
  final String message;

  UpdateMessage(this.message);

  @override
  List<Object?> get props => [message];
}
