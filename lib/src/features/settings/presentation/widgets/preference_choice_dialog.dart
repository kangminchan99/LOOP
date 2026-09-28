import 'package:flutter/material.dart';
import 'package:loop/l10n/app_localizations.dart';

// 언어/테마의 저장 중복 방지와 실패 안내를 공통으로 처리한다.
class PreferenceChoiceDialog<T> extends StatefulWidget {
  const PreferenceChoiceDialog({
    super.key,
    required this.title,
    required this.values,
    required this.selected,
    required this.label,
    required this.onChanged,
  });
  final String title;
  final List<T> values;
  final T selected;
  final String Function(T) label;
  final Future<void> Function(T) onChanged;

  @override
  State<PreferenceChoiceDialog<T>> createState() =>
      _PreferenceChoiceDialogState<T>();
}

class _PreferenceChoiceDialogState<T> extends State<PreferenceChoiceDialog<T>> {
  bool _saving = false;
  bool _failed = false;

  Future<void> _select(T value) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _failed = false;
    });
    try {
      await widget.onChanged(value);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final value in widget.values)
            ListTile(
              enabled: !_saving,
              selected: widget.selected == value,
              title: Text(widget.label(value)),
              trailing:
                  widget.selected == value ? const Icon(Icons.check) : null,
              onTap: _saving ? null : () => _select(value),
            ),
          if (_saving) const LinearProgressIndicator(),
          if (_failed)
            Semantics(
              liveRegion: true,
              child: Text(
                l10n.settingsSaveFailed,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.languageDialogClose),
        ),
      ],
    );
  }
}
