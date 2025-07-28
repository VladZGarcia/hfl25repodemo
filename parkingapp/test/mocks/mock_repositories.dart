import 'package:mocktail/mocktail.dart';
import 'package:shared/shared.dart';
import 'package:parkingapp/repositories/vehicle_repository.dart';
import 'package:parkingapp/repositories/parking_repository.dart';
import 'package:parkingapp/repositories/person_repository.dart';
import 'package:parkingapp/repositories/parking_space_repository.dart';

// Fakes
class FakeVehicle extends Fake implements Vehicle {}

class FakeParking extends Fake implements Parking {}

class FakePerson extends Fake implements Person {}

class FakeParkingSpace extends Fake implements Parkingspace {}

// Mocks
class MockVehicleRepository extends Mock implements VehicleRepository {}

class MockParkingRepository extends Mock implements ParkingRepository {}

class MockPersonRepository extends Mock implements PersonRepository {}

class MockParkingSpaceRepository extends Mock
    implements ParkingSpaceRepository {}
