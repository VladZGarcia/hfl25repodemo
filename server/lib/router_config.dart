/* import '../bin/server.dart'; */
import 'package:server/handlers/parking_handler.dart';
import 'package:server/handlers/parking_space_handler.dart';
import 'package:server/handlers/person_handlers.dart';
import 'package:server/handlers/vehicle_handlers.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class RouterConfig {
  static Router initialize() {
    final router = Router();

    // Add OPTIONS handler for CORS preflight requests
    router.options('/<ignored|.*>', (Request request) {
      return Response.ok(
        '',
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type',
        },
      );
    });

    /* router.get('/', _rootHandler);
      router.get('/echo/<message>', _echoHandler); */
    router.post('/persons', createPersonHandler);
    router.get('/persons', getPersonsHandler);
    router.get('/persons/<personId>', getPersonByIdHandler);
    router.put('/persons/<id>', updatePersonHandler);
    router.delete('/persons/<id>', deletePersonHandler);

    router.post('/vehicles', createVehicleHandler);
    router.get('/vehicles', getVehiclesHandler);
    router.get('/vehicles/<registrationNumber>', getVehicleByIdHandler);
    router.put('/vehicles/<id>', updateVehicleHandler);
    router.delete('/vehicles/<id>', deleteVehicleHandler);

    router.post('/parking_spaces', createParkingSpaceHandler);
    router.get('/parking_spaces', getParkingSpacesHandler);
    router.get('/parking_spaces/<spaceId>', getParkingSpaceByIdHandler);
    router.put('/parking_spaces/<id>', updateParkingSpaceHandler);
    router.delete('/parking_spaces/<id>', deleteParkingSpaceHandler);

    router.post('/parkings', createParkingHandler);
    router.get('/parkings', getParkingsHandler);
    router.get('/parkings/<vehicleId>', getParkingByIdHandler);
    router.put('/parkings/<id>', updateParkingHandler);
    router.delete('/parkings/<id>', deleteParkingHandler);

    return router;
  }
}
