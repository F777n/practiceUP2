import 'package:flutter/material.dart';

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool danger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            style: danger
                ? FilledButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                  )
                : null,
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

Future<void> showDeleteHelp(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Как работает удаление'),
        content: const Text(
          'Логическое удаление записывает в deletedAt текущее время. '
          'Запись пропадает из каталога, но остаётся в памяти. '
          'Её снова видно с переключателем «Показывать удалённые», '
          'и её можно восстановить.\n\n'
          'Физическое удаление стирает запись совсем.\n\n'
          'Флажки отмечают несколько строк. Кнопка «Скрыть выбранные» '
          'перед логическим удалением спрашивает подтверждение. '
          'При смене поиска, фильтра или страницы выделение сбрасывается.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Понятно'),
          ),
        ],
      );
    },
  );
}
