/// "Sutar" = 1/8 inch bar diameter (3-sutar = 3/8", 4-sutar = 1/2").
class SteelResult {
  final int barsAlongL, barsAlongW; // bars parallel to L / parallel to W
  final double netRunningFt, grossRunningFt; // gross includes allowance
  final double standardBars; // exact count of 40 ft bars
  final int standardBarsRounded;
  final double kgPerFt, totalKg, tons;
  SteelResult(this.barsAlongL, this.barsAlongW, this.netRunningFt, this.grossRunningFt,
      this.standardBars, this.standardBarsRounded, this.kgPerFt, this.totalKg)
      : tons = totalKg / 1000;
}

double sutarKgPerFt(double sutar) => sutar * sutar / 53;

/// Bars parallel to L are spaced across W (and vice-versa):
///   n_L = floor((W*12 - 2*cover)/s) + 1, each L ft long
///   n_W = floor((L*12 - 2*cover)/s) + 1, each W ft long
/// Check: 10x10 ft @ 6" c/c -> 21*10 + 21*10 = 420 ft; +10% = 462 ft;
/// /40 = 11.55 bars; 3-sutar -> 462 * 9/53 = 78.5 kg.
SteelResult estimateSlabSteel({
  required double lengthFt, required double widthFt,
  required double spacingIn, required double sutar,
  int layers = 1, double allowance = 0.10, double barLenFt = 40, double coverIn = 0,
}) {
  if ([lengthFt, widthFt, spacingIn, sutar, barLenFt].any((x) => x <= 0) || layers < 1) {
    throw ArgumentError('Dimensions, spacing and sutar must be > 0.');
  }
  int count(double spanFt) {
    final clear = spanFt * 12 - 2 * coverIn;
    if (clear < 0) throw ArgumentError('Cover exceeds slab size.');
    return (clear / spacingIn + 1e-9).floor() + 1;
  }
  final nL = count(widthFt), nW = count(lengthFt);
  final net = (nL * lengthFt + nW * widthFt) * layers;
  final gross = net * (1 + allowance);
  final bars = gross / barLenFt;
  final kgFt = sutarKgPerFt(sutar);
  return SteelResult(nL, nW, net, gross, bars, bars.ceil(), kgFt, gross * kgFt);
}
