int parsePage(String? raw) {
  final value = int.tryParse(raw ?? '');
  if (value == null || value < 1) return 1;
  return value;
}

int parsePageSize(String? raw) {
  switch (int.tryParse(raw ?? '')) {
    case 10:
    case 25:
    case 50:
      return int.parse(raw!);
    default:
      return 10;
  }
}

({String field, bool ascending}) parseSort(
  String? raw, {
  required Set<String> allowed,
  required String fallback,
}) {
  final parts = (raw ?? '').split(',');
  final field = parts.first;
  if (!allowed.contains(field)) {
    return (field: fallback, ascending: true);
  }
  return (field: field, ascending: parts.length < 2 || parts[1] != 'desc');
}

String buildLocation(String path, Map<String, String> params) {
  if (params.isEmpty) return path;
  final query = params.entries.map((entry) {
    final value = Uri.encodeQueryComponent(entry.value).replaceAll('%2C', ',');
    return '${Uri.encodeQueryComponent(entry.key)}=$value';
  }).join('&');
  return '$path?$query';
}

void addSort(
  Map<String, String> params,
  String field,
  bool ascending,
  String defaultField,
) {
  if (field == defaultField && ascending) return;
  params['sort'] = '$field,${ascending ? 'asc' : 'desc'}';
}
