import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parkingapp/blocs/vehicle/vehicle_bloc.dart';
import 'package:parkingapp/blocs/vehicle/vehicle_event.dart';
import 'package:parkingapp/blocs/vehicle/vehicle_state.dart';
import 'package:parkingapp/repositories/vehicle_repository.dart';
import 'package:parkingapp/repositories/parking_repository.dart';
import 'package:shared/shared.dart';

// Mocks and fakes
class MockVehicleRepository extends Mock implements VehicleRepository {}

class MockParkingRepository extends Mock implements ParkingRepository {}

class FakeVehicle extends Fake implements Vehicle {}

class FakeParking extends Fake implements Parking {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeVehicle());
    registerFallbackValue(FakeParking());
  });

  late MockVehicleRepository mockVehicleRepository;
  late MockParkingRepository mockParkingRepository;
  late VehicleBloc vehicleBloc;

  final testVehicle = Vehicle(
    '1',
    'ABC123',
    Person(id: 'p1', name: 'Test', personId: 1),
  );
  final testVehicles = [testVehicle];
  final testParking = Parking(
    'pk1',
    testVehicle,
    Parkingspace(
      'ps1', // id
      'space-001', // spaceId
      'Testgatan 1', // adress
      10, // pricePerHour
    ),
    DateTime(2023, 1, 1, 8, 0),
    DateTime(2023, 1, 1, 10, 0),
  );

  setUp(() {
    mockVehicleRepository = MockVehicleRepository();
    mockParkingRepository = MockParkingRepository();
    vehicleBloc = VehicleBloc(
      vehicleRepository: mockVehicleRepository,
      parkingRepository: mockParkingRepository,
    );
  });

  tearDown(() {
    vehicleBloc.close();
  });

  group('VehicleBloc', () {
    blocTest<VehicleBloc, VehicleState>(
      'emits [VehicleLoading, VehicleLoaded] when LoadVehicles succeeds',
      build: () {
        when(
          () => mockVehicleRepository.getAll(),
        ).thenAnswer((_) async => testVehicles);
        return vehicleBloc;
      },
      act: (bloc) => bloc.add(LoadVehicles()),
      expect: () => [VehicleLoading(), VehicleLoaded(testVehicles)],
    );

    blocTest<VehicleBloc, VehicleState>(
      'emits [VehicleLoading, VehicleError] when LoadVehicles fails',
      build: () {
        when(
          () => mockVehicleRepository.getAll(),
        ).thenThrow(Exception('error'));
        return vehicleBloc;
      },
      act: (bloc) => bloc.add(LoadVehicles()),
      expect: () => [VehicleLoading(), isA<VehicleError>()],
    );

    blocTest<VehicleBloc, VehicleState>(
      'calls addVehicle and then LoadVehicles when AddVehicle is added',
      build: () {
        when(
          () => mockVehicleRepository.addVehicle(any()),
        ).thenAnswer((_) async {
          return testVehicle;
        });
        when(
          () => mockVehicleRepository.getAll(),
        ).thenAnswer((_) async => testVehicles);
        return vehicleBloc;
      },
      act: (bloc) => bloc.add(AddVehicle(testVehicle)),
      expect: () => [VehicleLoading(), VehicleLoaded(testVehicles)],
      verify: (_) {
        verify(() => mockVehicleRepository.addVehicle(any())).called(1);
      },
    );

    blocTest<VehicleBloc, VehicleState>(
      'calls update and then LoadVehicles when UpdateVehicle is added',
      build: () {
        when(
          () => mockVehicleRepository.update(any()),
        ).thenAnswer((_) async {
          return testVehicle;
        });
        when(
          () => mockVehicleRepository.getAll(),
        ).thenAnswer((_) async => testVehicles);
        return vehicleBloc;
      },
      act: (bloc) => bloc.add(UpdateVehicle(testVehicle)),
      expect: () => [VehicleLoading(), VehicleLoaded(testVehicles)],
      verify: (_) {
        verify(() => mockVehicleRepository.update(any())).called(1);
      },
    );

    blocTest<VehicleBloc, VehicleState>(
      'deletes parkings and vehicle, then loads vehicles when DeleteVehicle is added',
      build: () {
        when(
          () => mockParkingRepository.getAll(),
        ).thenAnswer((_) async => [testParking]);
        when(
          () => mockParkingRepository.delete(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockVehicleRepository.delete(any()),
        ).thenAnswer((_) async {});
        when(() => mockVehicleRepository.getAll()).thenAnswer((_) async => []);
        return vehicleBloc;
      },
      act: (bloc) => bloc.add(DeleteVehicle('1')),
      expect: () => [VehicleLoading(), VehicleLoaded([])],
      verify: (_) {
        verify(() => mockParkingRepository.delete(any())).called(1);
        verify(() => mockVehicleRepository.delete(any())).called(1);
      },
    );

    blocTest<VehicleBloc, VehicleState>(
      'emits VehicleError when addVehicle throws',
      build: () {
        when(
          () => mockVehicleRepository.addVehicle(any()),
        ).thenThrow(Exception('error'));
        return vehicleBloc;
      },
      act: (bloc) => bloc.add(AddVehicle(testVehicle)),
      expect: () => [isA<VehicleError>()],
    );
  });
}
