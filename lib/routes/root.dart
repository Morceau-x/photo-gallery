import 'package:flutter/material.dart';
import 'package:photo_gallery/ui/pages/connections_page.dart';
import 'package:photo_gallery/ui/pages/edit_connection_page.dart';
import 'package:photo_gallery/ui/pages/home_page.dart';
import 'package:go_router/go_router.dart';

import 'home.dart';

part 'root.g.dart';

@TypedGoRoute<RootRoute>(
  path: '/',
  routes: <TypedGoRoute<GoRouteData>>[
    TypedGoRoute<HomeRoute>(path: 'home'),
    TypedGoRoute<ConnectionsRoute>(path: 'connections'),
    TypedGoRoute<EditConnectionRoute>(path: 'connections/:connectionId'),
  ],
)
class RootRoute extends GoRouteData with $RootRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) => HomePage();
}

class ConnectionsRoute extends GoRouteData with $ConnectionsRoute {
  const ConnectionsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ConnectionsPage();
}

class EditConnectionRoute extends GoRouteData with $EditConnectionRoute {
  const EditConnectionRoute({required this.connectionId});
  final String connectionId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      EditConnectionPage(connectionId: connectionId);
}

final GoRouter router = GoRouter(routes: $appRoutes);
