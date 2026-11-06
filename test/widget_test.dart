import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ring_shop/app.dart';

void main() {
  testWidgets('каталог открывается таблицей', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 1000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildRingApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Каталог товаров'), findsOneWidget);
    expect(find.textContaining('Everlast'), findsWidgets);
    expect(find.byType(DataTable), findsOneWidget);
    expect(find.textContaining('Страница 1 из'), findsOneWidget);
  });

  testWidgets('узкое окно показывает карточки', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(420, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(buildRingApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Каталог товаров'), findsOneWidget);
    expect(find.byType(DataTable), findsNothing);
    expect(find.byType(Checkbox), findsWidgets);
  });
}
