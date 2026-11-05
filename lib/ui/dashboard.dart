import 'package:flutter/material.dart';
import '../core/boq.dart';
import 'modules.dart';

const kGreen = Color(0xFF0B3D2E);
const kGold = Color(0xFFD4A537);

class _Mod {
  final String title, sub;
  final IconData icon;
  const _Mod(this.title, this.sub, this.icon);
}

const _mods = [
  _Mod('Masonry & Concrete', 'Bricks, mortar, cement, sand, crush, water', Icons.foundation),
  _Mod('Steel Estimator', 'Sutar bars, running ft, 40 ft bars, weight', Icons.grid_on),
  _Mod('Land Measurement', 'Marla, Kanal, Bigha, Heron, 3-4-5 Gunya', Icons.square_foot),
  _Mod('Town Planning', 'Plots, wastage, road width, red alert', Icons.map),
  _Mod('Finishing & BOQ', 'Plaster, earthwork, tiles, roads, PDF BOQ', Icons.receipt_long),
];

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _i = 0;
  late final List<Widget> _pages = [
    Dashboard(onOpen: (i) => setState(() => _i = i + 1)),
    masonryModule(), steelModule(), landModule(), planningModule(), finishingModule(),
  ];
  static const _titles = ['Dashboard', 'Masonry & Concrete', 'Steel Estimator', 'Land Measurement', 'Town Planning', 'Finishing & BOQ'];

  Widget get _body => _i == 0
      ? _pages[0]
      : Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 900), child: _pages[_i]));

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 800;
    final icons = [Icons.dashboard, ..._mods.map((m) => m.icon)];
    if (!wide) {
      return Scaffold(
        appBar: AppBar(title: const Text('UMAR Town Planner'), backgroundColor: kGreen, foregroundColor: Colors.white),
        body: SafeArea(child: _body),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _i, onDestinationSelected: (i) => setState(() => _i = i),
          destinations: [for (var k = 0; k < icons.length; k++) NavigationDestination(icon: Icon(icons[k]), label: _titles[k].split(' ').first)],
        ),
      );
    }
    final extended = MediaQuery.of(context).size.width >= 1100;
    return Scaffold(
      body: Row(children: [
        NavigationRail(
          backgroundColor: kGreen, extended: extended, selectedIndex: _i,
          onDestinationSelected: (i) => setState(() => _i = i),
          indicatorColor: kGold,
          selectedIconTheme: const IconThemeData(color: kGreen),
          unselectedIconTheme: const IconThemeData(color: Colors.white70),
          selectedLabelTextStyle: const TextStyle(color: kGold, fontWeight: FontWeight.bold),
          unselectedLabelTextStyle: const TextStyle(color: Colors.white70),
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(children: [
              ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.asset('assets/icon.png', width: 56, height: 56)),
              if (extended) ...[
                const SizedBox(height: 10),
                const Text('UMAR', style: TextStyle(color: kGold, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 4)),
                const Text('TOWN PLANNER', style: TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 2)),
              ],
            ]),
          ),
          destinations: [for (var k = 0; k < icons.length; k++) NavigationRailDestination(icon: Icon(icons[k]), label: Text(_titles[k]))],
        ),
        Expanded(child: _body),
      ]),
    );
  }
}

class Dashboard extends StatelessWidget {
  final void Function(int) onOpen;
  const Dashboard({super.key, required this.onOpen});

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(24), children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(colors: [Color(0xFF062A20), Color(0xFF14664B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 18, offset: Offset(0, 8))],
          ),
          child: Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(22), child: Image.asset('assets/icon.png', width: 96, height: 96)),
            const SizedBox(width: 24),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('UMAR TOWN PLANNER', style: TextStyle(color: kGold, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 3)),
              SizedBox(height: 6),
              Text('Civil Engineering  •  Town Planning  •  BOQ', style: TextStyle(color: Colors.white70, fontSize: 15, letterSpacing: 1.5)),
              SizedBox(height: 4),
              Text('Pakistan standards: Marla, Kanal, Sutar, Karam', style: TextStyle(color: Colors.white54, fontSize: 13)),
            ])),
          ]),
        ),
        const SizedBox(height: 24),
        ListenableBuilder(
          listenable: Boq.I,
          builder: (_, __) => Wrap(spacing: 16, runSpacing: 16, children: [
            _stat('BOQ items', '${Boq.I.items.length}', Icons.list_alt),
            _stat('BOQ total', 'Rs ${Boq.I.total.toStringAsFixed(0)}', Icons.payments),
            _stat('1 Kanal', '5445 sq.ft', Icons.straighten),
            _stat('1 Marla', '272.25 sq.ft', Icons.crop_square),
          ]),
        ),
        const SizedBox(height: 24),
        const Text('Tools', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kGreen)),
        const SizedBox(height: 12),
        Wrap(spacing: 16, runSpacing: 16, children: [
          for (var k = 0; k < _mods.length; k++)
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => onOpen(k),
              child: Container(
                width: 270, padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(18),
                  border: k == 3 ? Border.all(color: kGold, width: 2) : null,
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  CircleAvatar(radius: 24, backgroundColor: kGreen, child: Icon(_mods[k].icon, color: kGold)),
                  const SizedBox(height: 14),
                  Text(_mods[k].title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(_mods[k].sub, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                  if (k == 3) const Padding(padding: EdgeInsets.only(top: 8), child: Text('★ FLAGSHIP', style: TextStyle(color: kGold, fontWeight: FontWeight.bold, fontSize: 12))),
                ]),
              ),
            ),
        ]),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: kGreen.withOpacity(.07), borderRadius: BorderRadius.circular(16)),
          child: const Text(
            'Gross plot area = Width × (Depth + Road/2)   •   Plots = Usable land ÷ Gross plot   •   Steel weight = Sutar² ÷ 53 kg/ft',
            style: TextStyle(color: kGreen, fontWeight: FontWeight.w600)),
        ),
      ]);

  Widget _stat(String l, String v, IconData i) => Container(
        width: 200, padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))]),
        child: Row(children: [
          Icon(i, color: kGold, size: 30), const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l, style: const TextStyle(color: Colors.black54, fontSize: 12)),
            Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kGreen)),
          ])),
        ]),
      );
}
