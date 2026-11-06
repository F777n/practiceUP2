import 'dart:math' as math;

import 'package:flutter/material.dart';

class TableColumnSpec<T> {
  const TableColumnSpec({
    required this.label,
    required this.build,
    this.sortField,
    this.numeric = false,
  });

  final String label;
  final String? sortField;
  final bool numeric;
  final Widget Function(T item) build;
}

class EntityTable<T> extends StatefulWidget {
  const EntityTable({
    super.key,
    required this.columns,
    required this.items,
    required this.idOf,
    this.selected = const {},
    this.onToggleSelect,
    this.sortField,
    this.sortAscending = true,
    this.onSort,
    this.actions,
    this.isDimmed,
  });

  final List<TableColumnSpec<T>> columns;
  final List<T> items;
  final int Function(T item) idOf;
  final Set<int> selected;
  final ValueChanged<int>? onToggleSelect;
  final String? sortField;
  final bool sortAscending;
  final void Function(String field)? onSort;
  final List<Widget> Function(T item)? actions;
  final bool Function(T item)? isDimmed;

  @override
  State<EntityTable<T>> createState() => _EntityTableState<T>();
}

class _EntityTableState<T> extends State<EntityTable<T>> {
  final _vertical = ScrollController();
  final _horizontal = ScrollController();

  @override
  void dispose() {
    _vertical.dispose();
    _horizontal.dispose();
    super.dispose();
  }

  int? get _sortColumnIndex {
    if (widget.onSort == null || widget.sortField == null) return null;
    final index = widget.columns.indexWhere(
      (column) => column.sortField == widget.sortField,
    );
    if (index < 0 || widget.columns[index].sortField == null) return null;
    return index;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final minWidth = constraints.maxWidth.isFinite
            ? math.max(constraints.maxWidth, 1100.0)
            : 1100.0;
        return Scrollbar(
          controller: _vertical,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _vertical,
            child: Scrollbar(
              controller: _horizontal,
              thumbVisibility: true,
              notificationPredicate: (notification) {
                return notification.metrics.axis == Axis.horizontal;
              },
              child: SingleChildScrollView(
                controller: _horizontal,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: minWidth),
                  child: DataTable(
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: widget.sortAscending,
                    showCheckboxColumn: widget.onToggleSelect != null,
                    headingRowColor: WidgetStateProperty.all(
                      scheme.surfaceContainerHighest,
                    ),
                    columns: [
                      for (final column in widget.columns)
                        DataColumn(
                          label: Text(column.label),
                          numeric: column.numeric,
                          onSort: column.sortField == null || widget.onSort == null
                              ? null
                              : (_, __) => widget.onSort!(column.sortField!),
                        ),
                      if (widget.actions != null)
                        const DataColumn(label: Text('Действия')),
                    ],
                    rows: [
                      for (final item in widget.items)
                        DataRow(
                          selected: widget.selected.contains(widget.idOf(item)),
                          onSelectChanged: widget.onToggleSelect == null
                              ? null
                              : (_) => widget.onToggleSelect!(widget.idOf(item)),
                          color: _rowColor(scheme, item),
                          cells: [
                            for (final column in widget.columns)
                              DataCell(column.build(item)),
                            if (widget.actions != null)
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: widget.actions!(item),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  WidgetStateProperty<Color?> _rowColor(ColorScheme scheme, T item) {
    final dimmed = widget.isDimmed?.call(item) ?? false;
    return WidgetStateProperty.resolveWith((states) {
      if (dimmed) return scheme.errorContainer.withOpacity(0.45);
      if (states.contains(WidgetState.selected)) {
        return scheme.primaryContainer.withOpacity(0.55);
      }
      return null;
    });
  }
}
