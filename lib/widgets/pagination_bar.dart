import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.page,
    required this.totalPages,
    required this.totalLabel,
    required this.size,
    required this.onPage,
    required this.onSize,
  });

  final int page;
  final int totalPages;
  final String totalLabel;
  final int size;
  final ValueChanged<int> onPage;
  final ValueChanged<int> onSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final canBack = page > 1;
    final canForward = page < totalPages;
    return Wrap(
      spacing: 4,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      children: [
        IconButton(
          key: const Key('page-first'),
          tooltip: 'Первая страница',
          onPressed: canBack ? () => onPage(1) : null,
          icon: const Icon(Icons.first_page),
        ),
        IconButton(
          key: const Key('page-prev'),
          tooltip: 'Предыдущая страница',
          onPressed: canBack ? () => onPage(page - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        Text('Страница $page из $totalPages', style: theme.titleSmall),
        Text('Всего $totalLabel', style: theme.bodyMedium),
        IconButton(
          key: const Key('page-next'),
          tooltip: 'Следующая страница',
          onPressed: canForward ? () => onPage(page + 1) : null,
          icon: const Icon(Icons.chevron_right),
        ),
        IconButton(
          key: const Key('page-last'),
          tooltip: 'Последняя страница',
          onPressed: page == totalPages ? null : () => onPage(totalPages),
          icon: const Icon(Icons.last_page),
        ),
        const SizedBox(width: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('На странице', style: theme.bodyMedium),
            const SizedBox(width: 8),
            DropdownButton<int>(
              key: const Key('page-size'),
              value: size,
              items: const [
                DropdownMenuItem(value: 10, child: Text('10')),
                DropdownMenuItem(value: 25, child: Text('25')),
                DropdownMenuItem(value: 50, child: Text('50')),
              ],
              onChanged: (value) {
                if (value != null) onSize(value);
              },
            ),
          ],
        ),
      ],
    );
  }
}
