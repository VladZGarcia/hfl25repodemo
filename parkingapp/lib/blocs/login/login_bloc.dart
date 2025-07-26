import 'package:flutter_bloc/flutter_bloc.dart';
import '../login/login_event.dart';
import '../login/login_state.dart';
import 'package:parkingapp/repositories/person_repository.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final PersonRepository personRepository;
  LoginBloc({required this.personRepository}) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final persons = await personRepository.getAll();
      final bool emailExists = persons.any((person) => person.email == event.email);
      if (emailExists) {
        emit(LoginSuccess());
      } else {
        emit(const LoginFailure("Invalid email or password"));
      }
    } catch (e) {
      emit(const LoginFailure("Login failed"));
    }
  }
}