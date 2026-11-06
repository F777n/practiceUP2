import 'package:flutter/material.dart';

class EntityCardList<T> extends StatelessWidget {
  const EntityCardList({
    super.key,
    required this.items,
    required this.idOf,
    required this.body,
    this.selected = const {},
    this.onToggleSelect,
    this.actions,
    this.isDimmed,
  });

  final List<T> items;
  final int Function(T item) idOf;
  final Widget Function(BuildContext context, T item) body;
  final Set<int> selected;
  final ValueChanged<int>? onToggleSelect;
  final List<Widget> Function(T item)? actions;
  final bool Function(T item)? isDimmed;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 8),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final id = idOf(item);
        final dimmed = isDimmed?.call(item) ?? false;
        final scheme = Theme.of(context).colorScheme;
        return Card(
          color: dimmed ? scheme.errorContainer.withOpacity(0.35) : null,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 8, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (onToggleSelect != null)
                      Checkbox(
                        value: selected.contains(id),
                        onChanged: (_) => onToggleSelect!(id),
                      ),
                    Expanded(child: body(context, item)),
                  ],
                ),
                if (actions != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Wrap(children: actions!(item)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
