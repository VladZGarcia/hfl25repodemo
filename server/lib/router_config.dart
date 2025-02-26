
import 'package:server/handlers/person_handlers.dart';
import 'package:shelf_router/shelf_router.dart';

class RouterConfig {
  static Router initialize() {
    final router = Router();
    
      // ..get('/', _rootHandler)
      // ..get('/echo/<message>', _echoHandler)
      router.post('/persons', createPersonHandler);
      router.get('/persons', getPersonsHandler);
      router.get('/persons/<personId>', getPersonByIdHandler);
      router.put('/persons/<id>', updatePersonHandler);
      router.delete('/persons/<personId>', deletePersonHandler);

    return router;
  }
}