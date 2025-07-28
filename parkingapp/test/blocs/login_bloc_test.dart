import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parkingapp/blocs/login/login_bloc.dart';
import 'package:parkingapp/blocs/login/login_event.dart';
import 'package:parkingapp/blocs/login/login_state.dart';
import 'package:parkingapp/repositories/person_repository.dart';
import 'package:shared/shared.dart';

// Mock repository
class MockPersonRepository extends Mock implements PersonRepository {}

void main() {
  late MockPersonRepository mockPersonRepository;
  late LoginBloc loginBloc;

  setUp(() {
    mockPersonRepository = MockPersonRepository();
    loginBloc = LoginBloc(personRepository: mockPersonRepository);
  });

  tearDown(() {
    loginBloc.close();
  });

  final testPerson = Person(
    id: '1',
    name: 'Test User',
    email: 'test@example.com',
    password: 'password',
    personId: 123,
  );

  group('LoginBloc', () {
    blocTest<LoginBloc, LoginState>(
      'emits [LoginLoading, LoginSuccess] when login is successful',
      build: () {
        when(
          () => mockPersonRepository.getAll(),
        ).thenAnswer((_) async => [testPerson]);
        return LoginBloc(personRepository: mockPersonRepository);
      },
      act:
          (bloc) => bloc.add(
            LoginSubmitted(email: 'test@example.com', password: 'password'),
          ),
      expect: () => [isA<LoginLoading>(), isA<LoginSuccess>()],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [LoginLoading, LoginFailure] when login fails',
      build: () {
        when(() => mockPersonRepository.getAll()).thenAnswer((_) async => []);
        return LoginBloc(personRepository: mockPersonRepository);
      },
      act:
          (bloc) => bloc.add(
            LoginSubmitted(email: 'wrong@example.com', password: 'wrong'),
          ),
      expect: () => [isA<LoginLoading>(), isA<LoginFailure>()],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [LoginLoading, LoginFailure] when repository throws',
      build: () {
        when(() => mockPersonRepository.getAll()).thenThrow(Exception('error'));
        return LoginBloc(personRepository: mockPersonRepository);
      },
      act:
          (bloc) => bloc.add(
            LoginSubmitted(email: 'test@example.com', password: 'password'),
          ),
      expect: () => [isA<LoginLoading>(), isA<LoginFailure>()],
    );
  });
}
