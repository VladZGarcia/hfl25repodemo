import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parkingapp/blocs/ticket/ticket_bloc.dart';
import 'package:parkingapp/blocs/ticket/ticket_event.dart';
import 'package:parkingapp/blocs/ticket/ticket_state.dart';
import 'package:shared/shared.dart';

import '../mocks/mock_repositories.dart';



void main() {
  setUpAll(() {
    registerFallbackValue(FakeParking());
  });

  late MockParkingRepository mockParkingRepository;
  late TicketBloc ticketBloc;

  final testTicket = Parking(
    'pk1',
    Vehicle('v1', 'ABC123', Person(id: 'p1', name: 'Test', personId: 1)),
    Parkingspace('ps1', 'space-001', 'Testgatan 1', 10),
    DateTime(2023, 1, 1, 8, 0),
    DateTime(2023, 1, 1, 10, 0),
  );
  final testTickets = [testTicket];

  setUp(() {
    mockParkingRepository = MockParkingRepository();
    ticketBloc = TicketBloc(parkingRepository: mockParkingRepository);
  });

  tearDown(() {
    ticketBloc.close();
  });

  group('TicketBloc', () {
    blocTest<TicketBloc, TicketState>(
      'emits [TicketLoading, TicketLoaded] when LoadTickets succeeds',
      build: () {
        when(
          () => mockParkingRepository.getAll(),
        ).thenAnswer((_) async => testTickets);
        return ticketBloc;
      },
      act: (bloc) => bloc.add(LoadTickets()),
      expect: () => [TicketLoading(), TicketLoaded(testTickets)],
    );

    blocTest<TicketBloc, TicketState>(
      'emits [TicketLoading, TicketError] when LoadTickets fails',
      build: () {
        when(
          () => mockParkingRepository.getAll(),
        ).thenThrow(Exception('error'));
        return ticketBloc;
      },
      act: (bloc) => bloc.add(LoadTickets()),
      expect: () => [TicketLoading(), isA<TicketError>()],
    );

    blocTest<TicketBloc, TicketState>(
      'calls update and then LoadTickets when UpdateTicketEndTime is added',
      build: () {
        when(
          () => mockParkingRepository.update(any()),
        ).thenAnswer((_) async => testTicket);
        when(
          () => mockParkingRepository.getAll(),
        ).thenAnswer((_) async => testTickets);
        return ticketBloc;
      },
      act: (bloc) => bloc.add(UpdateTicketEndTime(testTicket, DateTime(2023, 1, 1, 12, 0))),
      expect: () => [TicketLoading(), TicketLoaded(testTickets)],
      verify: (_) {
        verify(() => mockParkingRepository.update(any())).called(1);
      },
    );

    blocTest<TicketBloc, TicketState>(
      'calls delete and then LoadTickets when DeleteTicket is added',
      build: () {
        when(
          () => mockParkingRepository.delete(any()),
        ).thenAnswer((_) async => null); // or use testTicket if you want
        when(() => mockParkingRepository.getAll()).thenAnswer((_) async => []);
        return ticketBloc;
      },
      act: (bloc) => bloc.add(DeleteTicket('pk1')),
      expect: () => [TicketLoading(), TicketLoaded([])],
      verify: (_) {
        verify(() => mockParkingRepository.delete(any())).called(1);
      },
    );

    blocTest<TicketBloc, TicketState>(
      'emits TicketError when update throws',
      build: () {
        when(
          () => mockParkingRepository.update(any()),
        ).thenThrow(Exception('update error'));
        return ticketBloc;
      },
      act: (bloc) => bloc.add(UpdateTicketEndTime(testTicket, DateTime(2023, 1, 1, 12, 0))),
      expect: () => [isA<TicketError>()],
    );

    blocTest<TicketBloc, TicketState>(
      'emits TicketError when delete throws',
      build: () {
        when(
          () => mockParkingRepository.delete(any()),
        ).thenThrow(Exception('delete error'));
        return ticketBloc;
      },
      act: (bloc) => bloc.add(DeleteTicket('pk1')),
      expect: () => [isA<TicketError>()],
    );
  });
}
