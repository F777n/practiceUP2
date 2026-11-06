import 'package:flutter_test/flutter_test.dart';
import 'package:ring_shop/data/catalog.dart';
import 'package:ring_shop/data/seed.dart';
import 'package:ring_shop/models/brand.dart';
import 'package:ring_shop/models/brand_query.dart';
import 'package:ring_shop/models/page_result.dart';
import 'package:ring_shop/models/product.dart';
import 'package:ring_shop/models/product_query.dart';
import 'package:ring_shop/repositories/in_memory_brand_repository.dart';
import 'package:ring_shop/repositories/in_memory_product_repository.dart';

void main() {
  test('стартовый каталог достаточно большой', () {
    final products = buildSeedProducts();
    final brands = buildSeedBrands();
    expect(products.length, greaterThanOrEqualTo(20));
    expect(brands.length, greaterThanOrEqualTo(8));
    expect(products.where((item) => item.isDeleted).length, greaterThan(0));
    expect(brands.where((item) => item.isDeleted).length, greaterThan(0));
    final brandIds = brands.map((item) => item.id).toSet();
    for (final product in products) {
      expect(brandIds, contains(product.brandId));
      expect(product.categoryIds, isNotEmpty);
      for (final id in product.categoryIds) {
        expect(productCategories.any((item) => item.id == id), isTrue);
      }
    }
    for (final brand in brands) {
      expect(brandCountries, contains(brand.country));
    }
  });

  test('copyWith сбрасывает страницу и умеет очищать фильтр', () {
    const query = ProductQuery(categoryId: 2, brandId: 4, page: 5, search: 'a');
    expect(query.copyWith(search: 'б').page, 1);
    expect(query.copyWith(search: 'б').categoryId, 2);
    expect(query.copyWith(categoryId: null).categoryId, isNull);
    expect(query.copyWith(categoryId: null).brandId, 4);
    expect(query.copyWith(page: 3).page, 3);
    expect(const ProductQuery().toLocation(), '/products');
  });

  test('адрес товара восстанавливает те же условия', () {
    const original = ProductQuery(
      search: 'перчатки',
      categoryId: 1,
      brandId: 3,
      yearFrom: 2020,
      yearTo: 2024,
      sortField: 'price',
      sortAscending: false,
      page: 2,
      size: 25,
      includeDeleted: true,
    );
    final parsed = ProductQuery.fromUri(Uri.parse(original.toLocation()));
    expect(parsed, original);
    expect(original.toLocation(), contains('sort=price,desc'));
    expect(original.toLocation(), contains('categoryId=1'));
    expect(original.toLocation(), contains('page=2'));
    expect(original.toLocation(), contains('deleted=1'));
  });

  test('битый размер страницы и сортировка заменяются значениями по умолчанию', () {
    final query = ProductQuery.fromUri(
      Uri.parse('/products?size=7&sort=nope,desc&page=0'),
    );
    expect(query.size, 10);
    expect(query.sortField, 'name');
    expect(query.sortAscending, isTrue);
    expect(query.page, 1);
  });

  test('clearDeletedAt отличает сброс от «не менять»', () {
    final hidden = buildSeedProducts().first.copyWith(
      deletedAt: DateTime.utc(2026, 1, 1),
    );
    expect(hidden.copyWith(name: 'Другое').isDeleted, isTrue);
    expect(hidden.copyWith(clearDeletedAt: true).deletedAt, isNull);
  });

  test('поиск, три фильтра, сортировка и страницы работают вместе', () async {
    final repo = InMemoryProductRepository(latency: Duration.zero);
    final page = await repo.find(
      const ProductQuery(
        search: 'перчатки',
        categoryId: 1,
        brandId: 1,
        yearFrom: 2020,
        yearTo: 2024,
        size: 10,
      ),
    );
    expect(page.items, isNotEmpty);
    expect(page.items.every((item) => item.brandId == 1), isTrue);
    expect(page.items.every((item) => item.categoryIds.contains(1)), isTrue);
    expect(page.items.every((item) => item.year >= 2020 && item.year <= 2024), isTrue);

    final bySku = await repo.find(const ProductQuery(search: 'ev-gl-10'));
    expect(bySku.total, 1);
    expect(bySku.items.single.name, contains('Everlast'));

    final sorted = await repo.find(
      const ProductQuery(size: 50, sortField: 'price', sortAscending: false),
    );
    final prices = sorted.items.map((item) => item.priceRub).toList();
    expect(prices, [...prices]..sort((a, b) => b.compareTo(a)));

    final first = await repo.find(const ProductQuery(size: 10));
    final second = await repo.find(const ProductQuery(page: 2, size: 10));
    expect(first.items, hasLength(10));
    expect(second.items, isNotEmpty);
    expect(first.total, 24);
    expect(second.total, first.total);
    expect(first.items.first.id, isNot(second.items.first.id));
  });

  test('deleteMany не трогает уже скрытые и прячет остальные', () async {
    final repo = InMemoryProductRepository(latency: Duration.zero);
    await repo.softDelete(1);
    final count = await repo.deleteMany([1, 2, 2]);
    expect(count, 1);
    expect((await repo.findById(1))!.isDeleted, isTrue);
    expect((await repo.findById(2))!.isDeleted, isTrue);
    final hidden = await repo.find(const ProductQuery(search: 'EV-GL-10'));
    expect(hidden.total, 0);
    final visible = await repo.find(
      const ProductQuery(search: 'EV-GL-10', includeDeleted: true),
    );
    expect(visible.total, 1);
    await repo.restore(1);
    expect((await repo.findById(1))!.isDeleted, isFalse);
    await repo.hardDelete(1);
    expect(await repo.findById(1), isNull);
    expect(repo.softDelete(9999), throwsStateError);
  });

  test('создание и обновление товара получают новый id', () async {
    final repo = InMemoryProductRepository(
      products: [
        const Product(
          id: 1,
          name: 'Тест',
          sku: 'T-1',
          year: 2020,
          priceRub: 1000,
          weightGrams: 300,
          brandId: 1,
          categoryIds: [1],
          stockTotal: 4,
          stockAvailable: 2,
        ),
      ],
      latency: Duration.zero,
    );
    final created = await repo.create(
      const Product(
        id: 0,
        name: 'Новые',
        sku: 'T-2',
        year: 2021,
        priceRub: 2000,
        weightGrams: 310,
        brandId: 1,
        categoryIds: [1],
        stockTotal: 3,
        stockAvailable: 1,
      ),
    );
    expect(created.id, 2);
    await repo.update(created.copyWith(name: 'Другие'));
    expect((await repo.findById(2))!.name, 'Другие');
  });

  test('бренд ищется по названию и стране', () async {
    final repo = InMemoryBrandRepository(latency: Duration.zero);
    final thailand = await repo.find(
      const BrandQuery(search: 'таиланд', size: 20, includeDeleted: true),
    );
    expect(thailand.total, greaterThanOrEqualTo(2));
    final exact = await repo.find(
      const BrandQuery(search: 'fairtex', country: 'Таиланд', size: 20),
    );
    expect(exact.items.single.name, 'Fairtex');
    final hidden = await repo.find(const BrandQuery(search: 'leone'));
    expect(hidden.total, 0);
    final withDeleted = await repo.find(
      const BrandQuery(search: 'leone', includeDeleted: true),
    );
    expect(withDeleted.total, 1);

    final parsed = BrandQuery.fromUri(
      Uri.parse(const BrandQuery(search: 'япония', country: 'Япония', page: 2).toLocation()),
    );
    expect(parsed.search, 'япония');
    expect(parsed.country, 'Япония');
    expect(parsed.page, 2);
  });

  test('пустая страница считает одну страницу', () {
    expect(PageResult<Brand>.empty().totalPages, 1);
    expect(PageResult<Brand>.empty().hasNext, isFalse);
    const page = PageResult<int>(items: [1], page: 2, size: 10, total: 25);
    expect(page.totalPages, 3);
    expect(page.hasPrevious, isTrue);
    expect(page.hasNext, isTrue);
  });
}
