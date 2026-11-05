import 'constants.dart';

class PlanningResult {
  final double totalSqft, usableSqft, plotArea, grossPlotArea, exactPlots;
  final int plots;
  final double netSaleable, saleablePerKanal, targetPerKanal;
  final double actualWastagePct, targetWastagePct, shortfallPerKanal;
  final bool meetsTarget;
  final double? maxRoadFt, minDepthFt;
  final List<String> suggestions;
  PlanningResult({
    required this.totalSqft, required this.usableSqft, required this.plotArea,
    required this.grossPlotArea, required this.exactPlots, required this.plots,
    required this.netSaleable, required this.saleablePerKanal, required this.targetPerKanal,
    required this.actualWastagePct, required this.targetWastagePct,
    required this.shortfallPerKanal, required this.meetsTarget,
    this.maxRoadFt, this.minDepthFt, required this.suggestions,
  });
}

/// gross plot = W * (D + road/2)       (plot owns half of the street in front)
/// usable land = total * (1 - amenities%)
/// plots = usable / gross              (floored for sale)
/// saleable per kanal = plots * W*D / totalKanals
/// With k = (1-a)*5445/T - 1 (T = target per kanal), target is met iff
///   road <= 2*D*k   or   D >= (road/2)/k.   Plot width cancels out.
/// Example: 200 kanal, 25x45, 30 ft road, 0% amenities -> gross 1500,
/// 726 plots, 4083.75 sq.ft/kanal (< 4500) -> RED ALERT; road <= 18.9 ft or depth >= 71.4 ft.
PlanningResult planLayout({
  required double totalKanals, required double targetPerKanal,
  required double plotW, required double plotD, required double roadFt,
  required double amenitiesPct,
}) {
  if ([totalKanals, targetPerKanal, plotW, plotD].any((x) => x <= 0) ||
      roadFt < 0 || amenitiesPct < 0 || amenitiesPct >= 100) {
    throw ArgumentError('Check inputs: sizes > 0, road >= 0, amenities in [0,100).');
  }
  if (targetPerKanal > kSqftPerKanal) throw ArgumentError('Target cannot exceed 5445 sq.ft per kanal.');
  final a = amenitiesPct / 100;
  final total = totalKanals * kSqftPerKanal;
  final usable = total * (1 - a);
  final plotArea = plotW * plotD;
  final gross = plotW * (plotD + roadFt / 2);
  final exact = usable / gross;
  final plots = exact.floor();
  final net = plots * plotArea;
  final perKanal = net / totalKanals;
  final meets = perKanal + 1e-6 >= targetPerKanal;

  final k = (1 - a) * kSqftPerKanal / targetPerKanal - 1;
  double? maxRoad, minDepth;
  final tips = <String>[];
  if (k <= 0) {
    tips.add('Amenities of ${fmt(amenitiesPct, 1)}% alone make this target unreachable. '
        'Keep amenities below ${fmt((1 - targetPerKanal / kSqftPerKanal) * 100, 1)}%.');
  } else {
    maxRoad = 2 * plotD * k;
    minDepth = (roadFt / 2) / k;
    if (!meets) {
      tips.add('Keep depth ${fmt(plotD, 0)} ft: road must be <= ${fmt(maxRoad, 1)} ft.');
      tips.add('Keep road ${fmt(roadFt, 0)} ft: depth must be >= ${fmt(minDepth, 1)} ft '
          '(e.g. ${fmt(plotW, 0)} x ${(minDepth / 5).ceil() * 5} ft).');
      tips.add('Plot width does not change the ratio; depth, road width and amenities do.');
    }
  }
  return PlanningResult(
    totalSqft: total, usableSqft: usable, plotArea: plotArea, grossPlotArea: gross,
    exactPlots: exact, plots: plots, netSaleable: net, saleablePerKanal: perKanal,
    targetPerKanal: targetPerKanal,
    actualWastagePct: (1 - net / total) * 100,
    targetWastagePct: (1 - targetPerKanal / kSqftPerKanal) * 100,
    shortfallPerKanal: meets ? 0 : targetPerKanal - perKanal, meetsTarget: meets,
    maxRoadFt: maxRoad, minDepthFt: minDepth, suggestions: tips,
  );
}
