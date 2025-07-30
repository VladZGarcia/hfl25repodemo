import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';
import '../login/login_event.dart';
import '../login/login_state.dart';
import 'package:parkingapp/repositories/person_repository.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final PersonRepository personRepository;
  LoginBloc({required this.personRepository}) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginEvent>(_onLoginEvent);
  }

  Future<void> _onLoginEvent(
    LoginEvent event,
    Emitter<LoginState> emit,
  ) async {
    FirebaseAuth.instance
  .authStateChanges()
  .listen((User? user) {
    if (user != null) {
      emit(LoginSuccess());
    } else {
      emit(LoginInitial());
    }
  });
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final persons = await personRepository.getAll();
      Person? loggedInPerson;
      try {
        loggedInPerson = persons.firstWhere(
          (person) => person.email == event.email,
        );
      } catch (e) {
        loggedInPerson = null;
      }
      final bool passwordMatches = loggedInPerson?.password == event.password;
      final bool emailExists = loggedInPerson != null;
      if (emailExists && passwordMatches) {
        emit(LoginSuccess());
      } else {
        emit(const LoginFailure("Invalid email or password"));
      }
    } catch (e) {
      emit(LoginFailure("Login failed: ${e.toString()}"));
    }
  }
}