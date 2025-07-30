import 'package:firebase_auth/firebase_auth.dart';
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
    final credential = await FirebaseAuth.instance.
    signInWithEmailAndPassword(
    email: event.email,
    password: event.password
  );
  if (credential.user == null) {
    emit(const LoginFailure("Failed to login"));
    return;
  } else {
    emit(LoginSuccess());
  }
} on FirebaseAuthException catch (e) {
  if (e.code == 'user-not-found') {
    emit(const LoginFailure('No user found for that email.'));
  } else if (e.code == 'wrong-password') {
    emit(const LoginFailure('Wrong password provided for that user.'));
  } else {
    emit(LoginFailure("Login failed: ${e.code}"));
  }
}
    
  }
}
