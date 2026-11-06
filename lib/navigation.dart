import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'models/brand_query.dart';
import 'models/product_query.dart';

class ListLocationMemory {
  String products = '/products';
  String brands = '/brands';
}

void goProductQuery(BuildContext context, ProductQuery next) {
  final current = ProductQuery.fromUri(GoRouterState.of(context).uri);
  if (current == next) return;
  final location = next.toLocation();
  context.read<ListLocationMemory>().products = location;
  context.go(location);
}

void goBrandQuery(BuildContext context, BrandQuery next) {
  final current = BrandQuery.fromUri(GoRouterState.of(context).uri);
  if (current == next) return;
  final location = next.toLocation();
  context.read<ListLocationMemory>().brands = location;
  context.go(location);
}
