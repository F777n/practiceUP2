import '../models/category.dart';

const productCategories = <Category>[
  Category(1, 'Перчатки'),
  Category(2, 'Бинты'),
  Category(3, 'Капы'),
  Category(4, 'Шлемы'),
  Category(5, 'Груши и мешки'),
  Category(6, 'Лапы'),
  Category(7, 'Обувь'),
  Category(8, 'Защита'),
];

const brandCountries = <String>[
  'США',
  'Канада',
  'Япония',
  'Мексика',
  'Германия',
  'Франция',
  'Россия',
  'Таиланд',
  'Италия',
];

String categoryName(int id) {
  for (final category in productCategories) {
    if (category.id == id) return category.name;
  }
  return 'Категория #$id';
}

String categoryLabel(List<int> ids) {
  if (ids.isEmpty) return '—';
  return ids.map(categoryName).join(', ');
}
