/// Shared constants. Change here, every module updates.
const double kCftPerCementBag = 1.25; // 1 bag (50 kg) ~ 1.25 cft
const double kMortarDryFactor = 1.27; // wet -> dry volume (mortar)
const double kConcreteDryFactor = 1.54; // wet -> dry volume (concrete)
const double kSqftPerKanal = 5445.0;
const double kSqftPerMarla = 272.25;
const double kAsphaltTonPerM3 = 2.35;
const double kFtToM = 0.3048;

String fmt(double v, [int d = 2]) => v.toStringAsFixed(d);
