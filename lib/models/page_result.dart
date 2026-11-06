class PageResult<T> {
  const PageResult({
    required this.items,
    required this.page,
    required this.size,
    required this.total,
  });

  final List<T> items;
  final int page;
  final int size;
  final int total;

  int get totalPages => total == 0 ? 1 : (total / size).ceil();

  bool get hasPrevious => page > 1;

  bool get hasNext => page < totalPages;

 
  PageResult.empty()
      : items = <T>[],
        page = 1,
        size = 10,
        total = 0;
}


PageResult<T> pageOf<T>(
  List<T> rows, {
  required int page,
  required int size,
}) {
  final total = rows.length;
  final safePage = page < 1 ? 1 : page;
  final safeSize = size < 1 ? 10 : size;
  final from = (safePage - 1) * safeSize;
  final to = from + safeSize > total ? total : from + safeSize;
  final items = from >= total || from < 0 ? <T>[] : rows.sublist(from, to);
  return PageResult(items: items, page: safePage, size: safeSize, total: total);
}
