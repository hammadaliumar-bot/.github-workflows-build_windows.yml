import 'dart:math';

enum LandUnit { sqft, sarsahi, marla, kanal, bigha, acre, murabba }

/// 1 Karam = 5.5 ft, 1 Sarsahi = 30.25 sqft, 1 Marla = 9 Sarsahi.
const Map<LandUnit, double> _sqft = {
  LandUnit.sqft: 1,
  LandUnit.sarsahi: 30.25,
  LandUnit.marla: 272.25,
  LandUnit.kanal: 5445, // 20 marla
  LandUnit.bigha: 21780, // 4 kanal
  LandUnit.acre: 43560, // 8 kanal (Killa)
  LandUnit.murabba: 1089000, // 25 acre
};

double convertLand(double v, LandUnit from, LandUnit to) => v * _sqft[from]! / _sqft[to]!;
double karamToFeet(double karam) => karam * 5.5;

double heron(double a, double b, double c) {
  if (a <= 0 || b <= 0 || c <= 0 || a + b <= c || a + c <= b || b + c <= a) {
    throw ArgumentError('Invalid triangle: sides ($a, $b, $c) violate the triangle inequality.');
  }
  final s = (a + b + c) / 2;
  return sqrt(s * (s - a) * (s - b) * (s - c));
}

/// Irregular 4-sided plot: triangle 1 = (a, b, diag), triangle 2 = (c, d, diag).
/// Four sides alone do not fix a quadrilateral, so one diagonal is required.
double quadArea(double a, double b, double c, double d, double diag) =>
    heron(a, b, diag) + heron(c, d, diag);

/// 3-4-5 rule for a right angle (Gunya). [scale] multiplies 3-4-5 (e.g. 3 -> 9-12-15 ft).
List<double> gunya345(double scale) => [3 * scale, 4 * scale, 5 * scale];

/// Diagonal a rectangle a x b must measure to be square.
double squareDiagonal(double a, double b) => sqrt(a * a + b * b);
