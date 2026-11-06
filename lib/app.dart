import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'navigation.dart';
import 'repositories/brand_repository.dart';
import 'repositories/in_memory_brand_repository.dart';
import 'repositories/in_memory_product_repository.dart';
import 'repositories/product_repository.dart';
import 'router.dart';
import 'state/brand_list_notifier.dart';
import 'state/product_list_notifier.dart';
import 'theme.dart';

Widget buildRingApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeController()),
      Provider(create: (_) => ListLocationMemory()),
      Provider<ProductRepository>(create: (_) => InMemoryProductRepository()),
      Provider<BrandRepository>(create: (_) => InMemoryBrandRepository()),
      ChangeNotifierProvider(
        create: (context) => ProductListNotifier(
          context.read<ProductRepository>(),
          context.read<BrandRepository>(),
        ),
      ),
      ChangeNotifierProvider(
        create: (context) => BrandListNotifier(context.read<BrandRepository>()),
      ),
    ],
    child: RingApp(router: createRouter()),
  );
}

class RingApp extends StatelessWidget {
  const RingApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    return MaterialApp.router(
      title: 'Ринг — боксёрские принадлежности',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: theme.mode,
      routerConfig: router,
      locale: const Locale('ru'),
      supportedLocales: const [Locale('ru'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      scrollBehavior: const AppScrollBehavior(),
    );
  }
}
