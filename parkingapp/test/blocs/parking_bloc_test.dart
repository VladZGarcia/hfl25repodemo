import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parkingapp/blocs/parking/parking_bloc.dart';
import 'package:parkingapp/blocs/parking/parking_event.dart';
import 'package:parkingapp/blocs/parking/parking_state.dart';
import 'package:shared/shared.dart';

import '../mocks/mock_repositories.dart';



void main() {
  setUpAll(() {
    registerFallbackValue(FakeParkingSpace());
    registerFallbackValue(FakeVehicle());
    registerFallbackValue(FakeParking()); // <-- Add this
  });

  late MockParkingRepository mockParkingRepository;
  late MockParkingSpaceRepository mockParkingSpaceRepository;
  late ParkingBloc parkingBloc;

  final testParkingSpace = Parkingspace('ps1', 'space-001', 'Testgatan 1', 10);
  final testParkingSpaces = [testParkingSpace];

  final testVehicle = Vehicle(
    '1',
    'ABC123',
    Person(id: 'p1', name: 'Test', personId: 1),
  );

  setUp(() {
    mockParkingRepository = MockParkingRepository();
    mockParkingSpaceRepository = MockParkingSpaceRepository();
    parkingBloc = ParkingBloc(
      parkingRepository: mockParkingRepository,
      parkingSpaceRepository: mockParkingSpaceRepository,
    );
  });

  tearDown(() {
    parkingBloc.close();
  });

  group('ParkingBloc', () {
    blocTest<ParkingBloc, ParkingState>(
      'emits loading and loaded when LoadParkingSpaces succeeds',
      build: () {
        when(
          () => mockParkingSpaceRepository.getAll(),
        ).thenAnswer((_) async => testParkingSpaces);
        return parkingBloc;
      },
      act: (bloc) => bloc.add(LoadParkingSpaces()),
      expect:
          () => [
            const ParkingState(isLoading: true),
            ParkingState(parkingSpaces: testParkingSpaces, isLoading: false),
          ],
    );

    blocTest<ParkingBloc, ParkingState>(
      'emits loading and error when LoadParkingSpaces fails',
      build: () {
        when(
          () => mockParkingSpaceRepository.getAll(),
        ).thenThrow(Exception('error'));
        return parkingBloc;
      },
      act: (bloc) => bloc.add(LoadParkingSpaces()),
      expect:
          () => [
            const ParkingState(isLoading: true),
            ParkingState(error: 'Exception: error', isLoading: false),
          ],
    );

    blocTest<ParkingBloc, ParkingState>(
      'emits state with selectedParkingSpace and selectedIndex when SelectParkingSpace is added',
      build: () => parkingBloc,
      act: (bloc) => bloc.add(SelectParkingSpace(testParkingSpace, 0)),
      expect:
          () => [
            isA<ParkingState>()
                .having(
                  (s) => s.selectedParkingSpace,
                  'selectedParkingSpace',
                  testParkingSpace,
                )
                .having((s) => s.selectedIndex, 'selectedIndex', 0)
                .having((s) => s.startTime, 'startTime', isA<TimeOfDay>()),
          ],
      verify: (bloc) {
        expect(bloc.state.selectedParkingSpace, testParkingSpace);
        expect(bloc.state.selectedIndex, 0);
      },
    );

    blocTest<ParkingBloc, ParkingState>(
      'emits new state with error when AddParkingEvent fails',
      build: () {
        when(
          () => mockParkingRepository.addParking(any()),
        ).thenThrow(Exception('add error'));
        return parkingBloc;
      },
      act:
          (bloc) => bloc.add(
            AddParkingEvent(
              vehicle: testVehicle,
              parkingSpace: testParkingSpace,
              startTime: DateTime(2020, 1, 1, 8, 0),
              endTime: DateTime(2020, 1, 1, 10, 0),
            ),
          ),
      expect:
          () => [
            isA<ParkingState>().having(
              (s) => s.error,
              'error',
              'Exception: add error',
            ),
          ],
    );

    blocTest<ParkingBloc, ParkingState>(
      'emits updated endTime and cost when UpdateParkingTimeEvent is added',
      build: () => parkingBloc,
      seed:
          () => ParkingState(
            startTime: const TimeOfDay(hour: 8, minute: 0),
            selectedParkingSpace: testParkingSpace,
          ),
      act:
          (bloc) => bloc.add(
            UpdateParkingTimeEvent(const TimeOfDay(hour: 10, minute: 0)),
          ),
      expect:
          () => [
            isA<ParkingState>()
                .having(
                  (s) => s.endTime,
                  'endTime',
                  const TimeOfDay(hour: 10, minute: 0),
                )
                .having((s) => s.cost, 'cost', 20.0),
          ],
    );
  });
}
