import 'package:flutter/material.dart';
import '../core/boq.dart';
import '../core/constants.dart';
import '../core/finishing.dart' as fin;
import '../core/land.dart';
import '../core/masonry.dart';
import '../core/planning.dart';
import '../core/steel.dart';
import 'calc_screen.dart';

Widget tabbed(List<(String, Widget)> tabs) => DefaultTabController(
      length: tabs.length,
      child: Column(children: [
        TabBar(isScrollable: true, tabs: [for (final t in tabs) Tab(text: t.$1)]),
        Expanded(child: TabBarView(children: [for (final t in tabs) t.$2])),
      ]),
    );

// ---------- MODULE 1 ----------
Widget masonryModule() => tabbed([
      ('Brickwork', CalcScreen(
        title: 'Brickwork',
        fields: const [
          FieldSpec('l', 'Wall length', 20, unit: 'ft'), FieldSpec('h', 'Wall height', 10, unit: 'ft'),
          FieldSpec('t', 'Wall thickness', 9, unit: 'in'),
          FieldSpec('bl', 'Brick length', 9, unit: 'in'), FieldSpec('bw', 'Brick width', 4.5, unit: 'in'),
          FieldSpec('bh', 'Brick height', 3, unit: 'in'), FieldSpec('j', 'Mortar joint', 0.5, unit: 'in'),
          FieldSpec('c', 'Cement part', 1), FieldSpec('s', 'Sand part', 4),
          FieldSpec('rb', 'Brick rate / 1000', 0, unit: 'Rs'), FieldSpec('rc', 'Cement rate / bag', 0, unit: 'Rs'),
          FieldSpec('rs', 'Sand rate / cft', 0, unit: 'Rs'),
        ],
        compute: (v) {
          final r = brickwork(lenFt: v['l']!, heightFt: v['h']!, thickIn: v['t']!, bL: v['bl']!, bW: v['bw']!,
              bH: v['bh']!, jointIn: v['j']!, cement: v['c']!, sand: v['s']!,
              ratePer1000Bricks: v['rb']!, rateCementBag: v['rc']!, rateSandCft: v['rs']!);
          return CalcOutput([
            ('Wall volume', '${fmt(r.wallVolCft)} cft'), ('Bricks', fmt(r.bricks, 0)),
            ('Wet mortar', '${fmt(r.wetMortarCft)} cft'), ('Dry mortar', '${fmt(r.dryMortarCft)} cft'),
            ('Cement', '${fmt(r.cementBags)} bags'), ('Sand', '${fmt(r.sandCft)} cft'),
            ('Total cost', 'Rs ${fmt(r.totalCost, 0)}'),
          ], boq: [
            BoqItem('Masonry', 'Bricks', 'nos', r.bricks, v['rb']! / 1000),
            BoqItem('Masonry', 'Cement (mortar)', 'bag', r.cementBags, v['rc']!),
            BoqItem('Masonry', 'Sand (mortar)', 'cft', r.sandCft, v['rs']!),
          ]);
        },
      )),
      ('Concrete', CalcScreen(
        title: 'Concrete',
        fields: const [
          FieldSpec('v', 'Wet volume (slab/column)', 100, unit: 'cft'),
          FieldSpec('c', 'Cement', 1), FieldSpec('s', 'Sand', 2), FieldSpec('a', 'Crush', 4),
          FieldSpec('wc', 'Water/cement ratio', 0.5),
          FieldSpec('rc', 'Cement rate / bag', 0, unit: 'Rs'), FieldSpec('rs', 'Sand rate / cft', 0, unit: 'Rs'),
          FieldSpec('rk', 'Crush rate / cft', 0, unit: 'Rs'),
        ],
        compute: (v) {
          final r = concrete(wetVolCft: v['v']!, c: v['c']!, s: v['s']!, a: v['a']!, wc: v['wc']!);
          return CalcOutput([
            ('Wet volume', '${fmt(r.wetCft)} cft'), ('Dry volume', '${fmt(r.dryCft)} cft'),
            ('Cement', '${fmt(r.cementBags)} bags'), ('Sand', '${fmt(r.sandCft)} cft'),
            ('Crush', '${fmt(r.crushCft)} cft'), ('Water', '${fmt(r.waterLiters, 0)} L'),
          ], boq: [
            BoqItem('Concrete', 'Cement', 'bag', r.cementBags, v['rc']!),
            BoqItem('Concrete', 'Sand', 'cft', r.sandCft, v['rs']!),
            BoqItem('Concrete', 'Crush', 'cft', r.crushCft, v['rk']!),
          ]);
        },
      )),
    ]);

// ---------- MODULE 2 ----------
Widget steelModule() => CalcScreen(
      title: 'Steel',
      fields: const [
        FieldSpec('l', 'Slab length', 10, unit: 'ft'), FieldSpec('w', 'Slab width', 10, unit: 'ft'),
        FieldSpec('s', 'Spacing c/c', 6, unit: 'in'), FieldSpec('su', 'Bar size (sutar)', 3),
        FieldSpec('ly', 'Layers (1 = one way mesh, 2 = top+bottom)', 1),
        FieldSpec('al', 'Allowance (hooks/cranks/wastage)', 10, unit: '%'),
        FieldSpec('cv', 'Edge cover', 0, unit: 'in'), FieldSpec('r', 'Rate per kg', 0, unit: 'Rs'),
      ],
      compute: (v) {
        final r = estimateSlabSteel(lengthFt: v['l']!, widthFt: v['w']!, spacingIn: v['s']!, sutar: v['su']!,
            layers: v['ly']!.round(), allowance: v['al']! / 100, coverIn: v['cv']!);
        return CalcOutput([
          ('Bars along length / width', '${r.barsAlongL} / ${r.barsAlongW}'),
          ('Net running ft', fmt(r.netRunningFt, 1)), ('With allowance', '${fmt(r.grossRunningFt, 1)} ft'),
          ('40 ft bars', '${fmt(r.standardBars)} (buy ${r.standardBarsRounded})'),
          ('Weight / ft', '${fmt(r.kgPerFt, 3)} kg'), ('Total weight', '${fmt(r.totalKg)} kg'),
          ('', '${fmt(r.tons, 3)} tons'),
        ], boq: [BoqItem('Steel', '${fmt(v['su']!, 0)}-sutar bars', 'kg', r.totalKg, v['r']!)]);
      },
    );

// ---------- MODULE 3 ----------
Widget landModule() => tabbed([
      ('Convert', const _LandConverter()),
      ('Heron (4 sides)', CalcScreen(
        title: 'Heron',
        fields: const [
          FieldSpec('a', 'Side AB', 40, unit: 'ft'), FieldSpec('b', 'Side BC', 30, unit: 'ft'),
          FieldSpec('c', 'Side CD', 45, unit: 'ft'), FieldSpec('d', 'Side DA', 35, unit: 'ft'),
          FieldSpec('g', 'Diagonal AC', 50, unit: 'ft'),
        ],
        compute: (v) {
          final ar = quadArea(v['a']!, v['b']!, v['c']!, v['d']!, v['g']!);
          return CalcOutput([
            ('Area', '${fmt(ar)} sq.ft'), ('Marla', fmt(ar / kSqftPerMarla)), ('Kanal', fmt(ar / kSqftPerKanal, 3)),
          ], tips: const ['Triangle 1 = AB, BC, AC. Triangle 2 = CD, DA, AC.']);
        },
      )),
      ('3-4-5 Gunya', CalcScreen(
        title: 'Gunya',
        fields: const [FieldSpec('k', 'Scale (3 -> 9-12-15 ft)', 3), FieldSpec('a', 'Check: side A', 40), FieldSpec('b', 'Check: side B', 30)],
        compute: (v) {
          final g = gunya345(v['k']!);
          return CalcOutput([
            ('Mark', '${fmt(g[0], 1)} - ${fmt(g[1], 1)} - ${fmt(g[2], 1)} ft'),
            ('Square diagonal for A x B', '${fmt(squareDiagonal(v['a']!, v['b']!))} ft'),
          ], tips: const ['Hypotenuse must match exactly for a true 90 degree corner.']);
        },
      )),
    ]);

class _LandConverter extends StatefulWidget {
  const _LandConverter();
  @override
  State<_LandConverter> createState() => _LandConverterState();
}

class _LandConverterState extends State<_LandConverter> {
  final _t = TextEditingController(text: '1');
  LandUnit _from = LandUnit.kanal;
  @override
  Widget build(BuildContext context) {
    final v = double.tryParse(_t.text) ?? 0;
    return ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [
        Expanded(child: TextField(controller: _t, onChanged: (_) => setState(() {}),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(border: OutlineInputBorder()))),
        const SizedBox(width: 12),
        DropdownButton<LandUnit>(value: _from, onChanged: (u) => setState(() => _from = u!),
            items: [for (final u in LandUnit.values) DropdownMenuItem(value: u, child: Text(u.name))]),
      ]),
      const SizedBox(height: 12),
      Card(child: Column(children: [
        for (final u in LandUnit.values)
          ListTile(dense: true, title: Text(u.name), trailing: Text(fmt(convertLand(v, _from, u), 4))),
      ])),
    ]);
  }
}

// ---------- MODULE 4 (flagship) ----------
Widget planningModule() => CalcScreen(
      title: 'Town Planning',
      fields: const [
        FieldSpec('land', 'Total land purchased', 200, unit: 'kanal'),
        FieldSpec('tgt', 'Target saleable per kanal', 4500, unit: 'sq.ft'),
        FieldSpec('pw', 'Plot width', 25, unit: 'ft'), FieldSpec('pd', 'Plot depth', 45, unit: 'ft'),
        FieldSpec('rd', 'Street / road width', 30, unit: 'ft'),
        FieldSpec('am', 'Amenities (parks, graveyard, commercial)', 0, unit: '%'),
      ],
      compute: (v) {
        final r = planLayout(totalKanals: v['land']!, targetPerKanal: v['tgt']!, plotW: v['pw']!,
            plotD: v['pd']!, roadFt: v['rd']!, amenitiesPct: v['am']!);
        return CalcOutput([
          ('Plot area', '${fmt(r.plotArea, 0)} sq.ft'),
          ('Gross plot area (incl. half road)', '${fmt(r.grossPlotArea, 0)} sq.ft'),
          ('Total plots', '${r.plots} (exact ${fmt(r.exactPlots)})'),
          ('Net saleable area', '${fmt(r.netSaleable, 0)} sq.ft'),
          ('Saleable per kanal', '${fmt(r.saleablePerKanal, 1)} sq.ft'),
          ('Actual wastage', '${fmt(r.actualWastagePct)} %'),
          ('Target wastage', '${fmt(r.targetWastagePct)} %'),
        ],
        alerts: r.meetsTarget ? const [] : [
          'RED ALERT: ${fmt(r.saleablePerKanal, 0)} sq.ft/kanal is ${fmt(r.shortfallPerKanal, 0)} below the ${fmt(r.targetPerKanal, 0)} target.'
        ],
        tips: r.meetsTarget ? const ['Target met.'] : r.suggestions);
      },
    );

// ---------- MODULE 5 ----------
Widget finishingModule() => tabbed([
      ('Plaster', CalcScreen(title: 'Plaster',
        fields: const [FieldSpec('a', 'Area', 1000, unit: 'sq.ft'), FieldSpec('t', 'Thickness', 0.5, unit: 'in'),
          FieldSpec('c', 'Cement', 1), FieldSpec('s', 'Sand', 4),
          FieldSpec('rc', 'Cement rate / bag', 0, unit: 'Rs'), FieldSpec('rs', 'Sand rate / cft', 0, unit: 'Rs')],
        compute: (v) {
          final m = fin.plaster(v['a']!, v['t']!, v['c']!, v['s']!);
          return CalcOutput([('Dry mortar', '${fmt(m.dryCft)} cft'), ('Cement', '${fmt(m.bags)} bags'), ('Sand', '${fmt(m.sandCft)} cft')],
              boq: [BoqItem('Plaster', 'Cement', 'bag', m.bags, v['rc']!), BoqItem('Plaster', 'Sand', 'cft', m.sandCft, v['rs']!)]);
        })),
      ('Earthwork', CalcScreen(title: 'Earthwork',
        fields: const [FieldSpec('l', 'Length', 100, unit: 'ft'), FieldSpec('w', 'Width', 3, unit: 'ft'),
          FieldSpec('d', 'Depth', 4, unit: 'ft'), FieldSpec('sw', 'Swell', 0, unit: '%'), FieldSpec('r', 'Rate / cft', 0, unit: 'Rs')],
        compute: (v) {
          final q = fin.excavationCft(v['l']!, v['w']!, v['d']!, swellPct: v['sw']!);
          return CalcOutput([('Excavation', '${fmt(q)} cft'), ('', '${fmt(q / 27)} cu.yd')],
              boq: [BoqItem('Earthwork', 'Excavation', 'cft', q, v['r']!)]);
        })),
      ('Tiles / Ceiling', CalcScreen(title: 'Tiles',
        fields: const [FieldSpec('a', 'Area', 500, unit: 'sq.ft'), FieldSpec('l', 'Tile length', 24, unit: 'in'),
          FieldSpec('w', 'Tile width', 24, unit: 'in'), FieldSpec('x', 'Wastage', 7, unit: '%'), FieldSpec('r', 'Rate / tile', 0, unit: 'Rs')],
        compute: (v) {
          final n = fin.tileCount(v['a']!, v['l']!, v['w']!, v['x']!);
          return CalcOutput([('Tiles needed', fmt(n, 0))], boq: [BoqItem('Finishing', 'Tiles / boards', 'nos', n, v['r']!)]);
        })),
      ('Roads & Sewer', CalcScreen(title: 'Roads',
        fields: const [FieldSpec('l', 'Road length', 1000, unit: 'ft'), FieldSpec('w', 'Road width', 30, unit: 'ft'),
          FieldSpec('t', 'Asphalt thickness', 2, unit: 'in'), FieldSpec('n', 'Sewer lines', 1),
          FieldSpec('ra', 'Asphalt rate / ton', 0, unit: 'Rs'), FieldSpec('rp', 'Pipe rate / ft', 0, unit: 'Rs')],
        compute: (v) {
          final r = fin.road(v['l']!, v['w']!, v['t']!, sewerLines: v['n']!.round());
          return CalcOutput([('Asphalt', '${fmt(r.asphaltM3)} m3'), ('', '${fmt(r.asphaltTons)} tons'),
            ('Sewer pipe', '${fmt(r.pipeLenFt, 0)} ft (${fmt(r.pipeJoints, 0)} joints)'), ('Manholes', fmt(r.manholes, 0))],
              boq: [BoqItem('Roads', 'Asphalt', 'ton', r.asphaltTons, v['ra']!), BoqItem('Sewer', 'Pipe', 'ft', r.pipeLenFt, v['rp']!)]);
        })),
      ('BOQ', const BoqView()),
    ]);

class BoqView extends StatelessWidget {
  const BoqView({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: Boq.I,
        builder: (_, __) => Column(children: [
          Expanded(child: ListView.builder(
            itemCount: Boq.I.items.length,
            itemBuilder: (_, i) {
              final e = Boq.I.items[i];
              return Dismissible(key: ObjectKey(e), onDismissed: (_) => Boq.I.removeAt(i),
                child: ListTile(dense: true, title: Text('${e.module}: ${e.description}'),
                    subtitle: Text('${fmt(e.qty)} ${e.unit} x ${fmt(e.rate)}'), trailing: Text('Rs ${fmt(e.amount, 0)}')));
            })),
          Padding(padding: const EdgeInsets.all(12), child: Row(children: [
            Expanded(child: Text('Total: Rs ${fmt(Boq.I.total, 0)}', style: const TextStyle(fontWeight: FontWeight.bold))),
            FilledButton.icon(onPressed: Boq.I.items.isEmpty ? null : () => Boq.I.sharePdf('Civil Project'),
                icon: const Icon(Icons.picture_as_pdf), label: const Text('Export PDF')),
          ])),
        ]),
      );
}
