import '../data/seed.dart';
import '../models/page_result.dart';
import '../models/product.dart';
import '../models/product_query.dart';
import 'product_repository.dart';

class InMemoryProductRepository implements ProductRepository {
  InMemoryProductRepository({
    List<Product>? products,
    this.latency = const Duration(milliseconds: 250),
  }) : _items = List<Product>.of(products ?? buildSeedProducts()) {
    _nextId = _items.fold<int>(0, (max, item) {
      return item.id > max ? item.id : max;
    }) +
        1;
  }

  final Duration latency;
  final List<Product> _items;
  late int _nextId;

  @override
  Future<PageResult<Product>> find(ProductQuery q) async {
    await Future.delayed(latency);
    var rows = _items.where((item) => q.includeDeleted || !item.isDeleted).toList();
    final needle = q.search.trim().toLowerCase();
    if (needle.isNotEmpty) {
      rows = rows
          .where(
            (item) =>
                item.name.toLowerCase().contains(needle) ||
                item.sku.toLowerCase().contains(needle),
          )
          .toList();
    }
    if (q.categoryId != null) {
      rows = rows.where((item) => item.categoryIds.contains(q.categoryId)).toList();
    }
    if (q.brandId != null) {
      rows = rows.where((item) => item.brandId == q.brandId).toList();
    }
    if (q.yearFrom != null) {
      rows = rows.where((item) => item.year >= q.yearFrom!).toList();
    }
    if (q.yearTo != null) {
      rows = rows.where((item) => item.year <= q.yearTo!).toList();
    }
    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'year' => a.year.compareTo(b.year),
        'price' => a.priceRub.compareTo(b.priceRub),
        _ => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      };
      return q.sortAscending ? result : -result;
    });
    return pageOf(rows, page: q.page, size: q.size);
  }

  @override
  Future<Product?> findById(int id) async {
    await Future.delayed(latency);
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<Product> create(Product draft) async {
    final created = Product(
      id: _nextId++,
      name: draft.name,
      sku: draft.sku,
      year: draft.year,
      priceRub: draft.priceRub,
      weightGrams: draft.weightGrams,
      brandId: draft.brandId,
      categoryIds: draft.categoryIds,
      stockTotal: draft.stockTotal,
      stockAvailable: draft.stockAvailable,
    );
    _items.add(created);
    return created;
  }

  @override
  Future<Product> update(Product product) async {
    final index = _items.indexWhere((item) => item.id == product.id);
    if (index == -1) throw StateError('Товар ${product.id} не найден');
    _items[index] = product;
    return product;
  }

  @override
  Future<void> softDelete(int id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) throw StateError('Товар $id не найден');
    _items[index] = _items[index].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    final removed = _items.length;
    _items.removeWhere((item) => item.id == id);
    if (_items.length == removed) throw StateError('Товар $id не найден');
  }

  @override
  Future<void> restore(int id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) throw StateError('Товар $id не найден');
    _items[index] = _items[index].copyWith(clearDeletedAt: true);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    // В методичке здесь было: !b[i].isDeleted.
    // У модели нет оператора [], а i ещё не объявлен — код не компилируется.
    // Проверять нужно флаг самого элемента и не считать уже скрытые записи.
    var count = 0;
    for (final id in ids) {
      final index = _items.indexWhere((item) => item.id == id && !item.isDeleted);
      if (index == -1) continue;
      _items[index] = _items[index].copyWith(deletedAt: DateTime.now());
      count++;
    }
    return count;
  }
}
