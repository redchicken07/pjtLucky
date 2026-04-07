import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/saju_result.dart';
import '../screens/birth_screen.dart';
import '../screens/cards_screen.dart';
import '../screens/home_screen.dart';
import '../screens/saju_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: '/birth',
        builder: (BuildContext context, GoRouterState state) {
          return const BirthScreen();
        },
      ),
      GoRoute(
        path: '/saju',
        builder: (BuildContext context, GoRouterState state) {
          final Object? extra = state.extra;
          return SajuScreen(initialResult: extra is SajuResult ? extra : null);
        },
      ),
      GoRoute(
        path: '/cards',
        builder: (BuildContext context, GoRouterState state) {
          return const CardsScreen();
        },
      ),
    ],
  );
}
