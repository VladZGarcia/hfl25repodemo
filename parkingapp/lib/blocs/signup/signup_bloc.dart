import 'package:flutter_bloc/flutter_bloc.dart';
import 'signup_event.dart';
import 'signup_state.dart';
import 'package:parkingapp/repositories/person_repository.dart';
import 'package:shared/shared.dart';
import 'package:uuid/uuid.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final PersonRepository personRepository;

  SignupBloc({required this.personRepository}) : super(SignupInitial()) {
    on<SignupSubmitted>(_onSignupSubmitted);
  }

  Future<void> _onSignupSubmitted(
    SignupSubmitted event,
    Emitter<SignupState> emit,
  ) async {
    emit(SignupLoading());
    if (event.password != event.confirmPassword) {
      emit(const SignupFailure("Passwords do not match"));
      return;
    }
    try {
      final persons = await personRepository.getAll();
      final emailExists = persons.any((person) => person.email == event.email);
      if (emailExists) {
        emit(const SignupFailure("Email already exists"));
        return;
      }
      var uuid = Uuid();
      await personRepository.addPerson(
        Person(
          id: uuid.v4(),
          name: event.username,
          email: event.email,
          password: event.password,
        ),
      );
      emit(SignupSuccess());
    } catch (e) {
      emit(const SignupFailure("Error creating account"));
    }
  }
}
