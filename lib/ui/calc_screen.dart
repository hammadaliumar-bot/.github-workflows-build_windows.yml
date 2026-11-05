import 'package:flutter/material.dart';
import '../core/boq.dart';

/// Declarative input field. Rate fields (cost inputs) are just normal fields.
class FieldSpec {
  final String key, label, unit;
  final double def;
  const FieldSpec(this.key, this.label, this.def, {this.unit = ''});
}

class CalcOutput {
  final List<(String, String)> rows;
  final List<String> alerts, tips; // alerts render as a red banner
  final bool ok; // false -> red alert, true & alerts empty -> green
  final List<BoqItem> boq;
  const CalcOutput(this.rows, {this.alerts = const [], this.tips = const [], this.boq = const []})
      : ok = true;
}

/// One reusable screen for every calculator: fields in -> compute() -> results.
class CalcScreen extends StatefulWidget {
  final String title;
  final List<FieldSpec> fields;
  final CalcOutput Function(Map<String, double> v) compute;
  const CalcScreen({super.key, required this.title, required this.fields, required this.compute});
  @override
  State<CalcScreen> createState() => _CalcScreenState();
}

class _CalcScreenState extends State<CalcScreen> {
  late final Map<String, TextEditingController> _c = {
    for (final f in widget.fields) f.key: TextEditingController(text: f.def.toString())
  };
  CalcOutput? _out;
  String? _err;

  void _run() {
    final v = {for (final e in _c.entries) e.key: double.tryParse(e.value.text) ?? 0};
    try {
      setState(() { _out = widget.compute(v); _err = null; });
    } on ArgumentError catch (e) {
      setState(() { _out = null; _err = e.message.toString(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(padding: const EdgeInsets.all(16), children: [
      for (final f in widget.fields)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
            controller: _c[f.key],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: f.label, suffixText: f.unit,
                border: const OutlineInputBorder()),
          ),
        ),
      FilledButton.icon(onPressed: _run, icon: const Icon(Icons.calculate), label: const Text('Calculate')),
      if (_err != null) _banner(_err!, Colors.orange.shade100, Icons.error_outline),
      if (_out != null) ...[
        const SizedBox(height: 12),
        for (final a in _out!.alerts) _banner(a, Colors.red.shade100, Icons.warning_amber_rounded, strong: true),
        if (_out!.alerts.isEmpty && _out!.tips.isEmpty) const SizedBox(),
        Card(child: Column(children: [
          for (final r in _out!.rows)
            ListTile(dense: true, title: Text(r.$1),
                trailing: Text(r.$2, style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary))),
        ])),
        for (final t in _out!.tips) _banner(t, Colors.blue.shade50, Icons.lightbulb_outline),
        if (_out!.boq.isNotEmpty)
          OutlinedButton.icon(
            onPressed: () {
              Boq.I.add(_out!.boq);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to BOQ')));
            },
            icon: const Icon(Icons.playlist_add), label: const Text('Add to BOQ')),
      ],
    ]);
  }

  Widget _banner(String t, Color bg, IconData i, {bool strong = false}) => Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10),
            border: strong ? Border.all(color: Colors.red, width: 1.5) : null),
        child: Row(children: [
          Icon(i, color: strong ? Colors.red : null), const SizedBox(width: 10),
          Expanded(child: Text(t, style: TextStyle(fontWeight: strong ? FontWeight.bold : null))),
        ]),
      );
}
