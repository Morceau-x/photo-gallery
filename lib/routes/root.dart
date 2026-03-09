import 'package:flutter/material.dart';
import 'package:photo_gallery/ui/pages/home_page.dart';
import 'package:go_router/go_router.dart';

import 'home.dart';

part 'root.g.dart';

@TypedGoRoute<RootRoute>(
  path: '/',
  routes: <TypedGoRoute<GoRouteData>>[TypedGoRoute<HomeRoute>(path: 'home')],
)
class RootRoute extends GoRouteData with $RootRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) => HomePage();
}

final GoRouter router = GoRouter(routes: $appRoutes);
