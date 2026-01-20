import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_event.dart';
import 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppState()) {
    on<InitializeApp>((event, emit) {
      emit(
        state.copyWith(status: AppStatus.success, message: "State initialized"),
      );
    });

    on<UpdateMessage>((event, emit) {
      emit(state.copyWith(status: AppStatus.success, message: event.message));
    });
  }
}
