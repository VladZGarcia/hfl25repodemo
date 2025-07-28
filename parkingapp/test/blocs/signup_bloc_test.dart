import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parkingapp/blocs/signup/signup_bloc.dart';
import 'package:parkingapp/blocs/signup/signup_event.dart';
import 'package:parkingapp/blocs/signup/signup_state.dart';
import 'package:parkingapp/repositories/person_repository.dart';
import 'package:shared/shared.dart';

// Mock repository
class MockPersonRepository extends Mock implements PersonRepository {}

class FakePerson extends Fake implements Person {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakePerson());
  });

  late MockPersonRepository mockPersonRepository;
  late SignupBloc signupBloc;

  setUp(() {
    mockPersonRepository = MockPersonRepository();
    signupBloc = SignupBloc(personRepository: mockPersonRepository);
  });

  tearDown(() {
    signupBloc.close();
  });

  final testPerson = Person(
    id: '1',
    name: 'Test User',
    email: 'test@example.com',
    password: 'password',
  );

  group('SignupBloc', () {
    blocTest<SignupBloc, SignupState>(
      'emits [SignupLoading, SignupSuccess] when signup is successful',
      build: () {
        when(() => mockPersonRepository.getAll()).thenAnswer((_) async => []);
        when(
          () => mockPersonRepository.addPerson(any()),
        ).thenAnswer((invocation) async => testPerson);
        return SignupBloc(personRepository: mockPersonRepository);
      },
      act:
          (bloc) => bloc.add(
            SignupSubmitted(
              username: 'Test User',
              email: 'test@example.com',
              password: 'password',
              confirmPassword: 'password',
            ),
          ),
      expect: () => [SignupLoading(), SignupSuccess()],
    );

    blocTest<SignupBloc, SignupState>(
      'emits [SignupLoading, SignupFailure] when passwords do not match',
      build: () => signupBloc,
      act:
          (bloc) => bloc.add(
            SignupSubmitted(
              username: 'Test User',
              email: 'test@example.com',
              password: 'password1',
              confirmPassword: 'password2',
            ),
          ),
      expect:
          () => [
            SignupLoading(),
            const SignupFailure("Passwords do not match"),
          ],
    );

    blocTest<SignupBloc, SignupState>(
      'emits [SignupLoading, SignupFailure] when email already exists',
      build: () {
        when(
          () => mockPersonRepository.getAll(),
        ).thenAnswer((_) async => [testPerson]);
        return SignupBloc(personRepository: mockPersonRepository);
      },
      act:
          (bloc) => bloc.add(
            SignupSubmitted(
              username: 'Test User',
              email: 'test@example.com',
              password: 'password',
              confirmPassword: 'password',
            ),
          ),
      expect:
          () => [SignupLoading(), const SignupFailure("Email already exists")],
    );

    blocTest<SignupBloc, SignupState>(
      'emits [SignupLoading, SignupFailure] when repository throws',
      build: () {
        when(() => mockPersonRepository.getAll()).thenThrow(Exception('error'));
        return SignupBloc(personRepository: mockPersonRepository);
      },
      act:
          (bloc) => bloc.add(
            SignupSubmitted(
              username: 'Test User',
              email: 'test@example.com',
              password: 'password',
              confirmPassword: 'password',
            ),
          ),
      expect:
          () => [
            SignupLoading(),
            const SignupFailure("Error creating account"),
          ],
    );
  });
}
