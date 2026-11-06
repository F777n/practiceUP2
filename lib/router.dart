import 'package:go_router/go_router.dart';

import 'models/brand_query.dart';
import 'models/product_query.dart';
import 'screens/app_shell.dart';
import 'screens/brand_details_screen.dart';
import 'screens/brand_list_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/product_details_screen.dart';
import 'screens/product_list_screen.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/products',
    redirect: (context, state) {
      if (state.uri.path == '/') return '/products';
      return null;
    },
    errorBuilder: (context, state) {
      return NotFoundScreen(location: state.uri.toString());
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/products',
            builder: (context, state) {
              return ProductListScreen(query: ProductQuery.fromUri(state.uri));
            },
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = int.tryParse(state.pathParameters['id'] ?? '');
                  if (id == null) {
                    return InvalidIdPage(location: state.uri.toString());
                  }
                  return ProductDetailsPage(id: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/brands',
            builder: (context, state) {
              return BrandListScreen(query: BrandQuery.fromUri(state.uri));
            },
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = int.tryParse(state.pathParameters['id'] ?? '');
                  if (id == null) {
                    return InvalidIdPage(location: state.uri.toString());
                  }
                  return BrandDetailsPage(id: id);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
