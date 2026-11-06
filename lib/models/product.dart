class Product {
  const Product({
    required this.id,
    required this.name,
    required this.sku,
    required this.year,
    required this.priceRub,
    required this.weightGrams,
    required this.brandId,
    required this.categoryIds,
    required this.stockTotal,
    required this.stockAvailable,
    this.deletedAt,
  });

  final int id;
  final String name;
  final String sku;
  final int year;
  final int priceRub;
  final int weightGrams;
  final int brandId;
  final List<int> categoryIds;
  final int stockTotal;
  final int stockAvailable;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  Product copyWith({
    String? name,
    String? sku,
    int? year,
    int? priceRub,
    int? weightGrams,
    int? brandId,
    List<int>? categoryIds,
    int? stockTotal,
    int? stockAvailable,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      year: year ?? this.year,
      priceRub: priceRub ?? this.priceRub,
      weightGrams: weightGrams ?? this.weightGrams,
      brandId: brandId ?? this.brandId,
      categoryIds: categoryIds ?? this.categoryIds,
      stockTotal: stockTotal ?? this.stockTotal,
      stockAvailable: stockAvailable ?? this.stockAvailable,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}
