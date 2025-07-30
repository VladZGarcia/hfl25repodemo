import 'package:firebase_auth/firebase_auth.dart';
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
      /* final persons = await personRepository.getAll();
      final emailExists = persons.any((person) => person.email == event.email);
      if (emailExists) {
        emit(const SignupFailure("Email already exists"));
        return;
      } */
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: event.email,
            password: event.password,
          );
      if (credential.user == null) {
        emit(const SignupFailure("Failed to create account"));
        return;
      }else {
        final uuid = Uuid();
        await personRepository.addPerson(
          Person(
            id: uuid.v4(),
            name: event.username,
            email: event.email,
            password: event.password,
            // personId can be set to null or a specific value if needed
            personId: 1234567890,
          ),
          
        );
        emit(SignupSuccess());
      }

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(const SignupFailure("The password provided is too weak."));
        return;
      } else if (e.code == 'invalid-email') {
        emit(const SignupFailure("The email address is not valid."));
        return;
      } else if (e.code == 'email-already-in-use') {
        emit(const SignupFailure("The account already exists for that email."));
        return;
      } else {
        emit( SignupFailure('error: ${e.code}'));
        return;
      } 
      
    } catch (e) {
      emit( SignupFailure('error: ${e.toString()}'));
    }
  }
}
