import 'dart:io';

import 'package:server/router_config.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

// Configure routes.


// Response _rootHandler(Request req) {
//   return Response.ok('Hello, World!\n');
// }

// Response _echoHandler(Request request) {
//   final message = request.params['message'];
//   return Response.ok('$message\n');
// }



void main(List<String> args) async {
  // Use any available host or container IP (usually `0.0.0.0`).
  final ip = InternetAddress.anyIPv4;
  Router router = RouterConfig.initialize();

  // Configure a pipeline that logs requests.
  final handler =
      Pipeline().addMiddleware(logRequests()).addHandler(router.call);

  // For running in containers, we respect the PORT environment variable.
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, ip, port);
  print('Server listening on port ${server.port}');
}
