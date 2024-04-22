import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:next_cloud_plans/repository/user_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final UserRepository userRepository;

  LoginBloc({required this.userRepository}) : super(LoginInitial()) {
    on<LoginCredentialsAdded>(_onLoginCredentialsAdded);
  }

  Future<void> _onLoginCredentialsAdded(
    LoginCredentialsAdded event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    final success = await userRepository.login(event.username, event.password);
    if (success) {
      emit(LoginSuccess());

      await userRepository.saveCredentials(
        username: event.username,
        password: event.password,
      );
    } else {
      emit(LoginFailure());
      if (kDebugMode) {
        print("failed");
      }
    }
  }
}
