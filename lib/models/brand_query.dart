import 'query_codec.dart';

class BrandQuery {
  const BrandQuery({
    this.search = '',
    this.country,
    this.sortField = 'name',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
  });

  final String search;
  final String? country;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;

  static const allowedSort = {'name', 'country', 'foundedYear'};

  factory BrandQuery.fromUri(Uri uri) {
    final params = uri.queryParameters;
    final sort = parseSort(
      params['sort'],
      allowed: allowedSort,
      fallback: 'name',
    );
    final country = params['country'];
    return BrandQuery(
      search: params['search'] ?? '',
      country: country == null || country.isEmpty ? null : country,
      sortField: sort.field,
      sortAscending: sort.ascending,
      page: parsePage(params['page']),
      size: parsePageSize(params['size']),
      includeDeleted: params['deleted'] == '1',
    );
  }

  String toLocation() {
    final params = <String, String>{};
    if (search.isNotEmpty) params['search'] = search;
    if (country != null) params['country'] = country!;
    addSort(params, sortField, sortAscending, 'name');
    if (page != 1) params['page'] = '$page';
    if (size != 10) params['size'] = '$size';
    if (includeDeleted) params['deleted'] = '1';
    return buildLocation('/brands', params);
  }

  BrandQuery copyWith({
    String? search,
    Object? country = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return BrandQuery(
      search: search ?? this.search,
      country: country == _unset ? this.country : country as String?,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }

  static const _unset = Object();

  @override
  bool operator ==(Object other) {
    return other is BrandQuery &&
        other.search == search &&
        other.country == country &&
        other.sortField == sortField &&
        other.sortAscending == sortAscending &&
        other.page == page &&
        other.size == size &&
        other.includeDeleted == includeDeleted;
  }

  @override
  int get hashCode => Object.hash(
        search,
        country,
        sortField,
        sortAscending,
        page,
        size,
        includeDeleted,
      );

  @override
  String toString() => toLocation();
}
