import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Не короче 300 мс: выборка не стартует на каждый символ.
const kFilterInputDelay = Duration(milliseconds: 350);

class DelayedSearchField extends StatefulWidget {
  const DelayedSearchField({
    super.key,
    required this.value,
    required this.onDebounced,
    required this.label,
    this.hint,
    this.delay = kFilterInputDelay,
    this.keyboardType,
    this.digitsOnly = false,
    this.prefixIcon,
  });

  final String value;
  final ValueChanged<String> onDebounced;
  final String label;
  final String? hint;
  final Duration delay;
  final TextInputType? keyboardType;
  final bool digitsOnly;
  final IconData? prefixIcon;

  @override
  State<DelayedSearchField> createState() => _DelayedSearchFieldState();
}

class _DelayedSearchFieldState extends State<DelayedSearchField> {
  late final TextEditingController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant DelayedSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String _) {
    _timer?.cancel();
    _timer = Timer(widget.delay, () {
      if (!mounted) return;
      widget.onDebounced(_controller.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      keyboardType: widget.keyboardType,
      inputFormatters: [
        if (widget.digitsOnly) FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: _onChanged,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon == null ? null : Icon(widget.prefixIcon),
      ),
    );
  }
}
