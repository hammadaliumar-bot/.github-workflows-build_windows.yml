import 'constants.dart';

class Mix { final double bags, sandCft, dryCft; Mix(this.bags, this.sandCft, this.dryCft); }

Mix plaster(double areaSqft, double thickIn, double cement, double sand) {
  if (areaSqft <= 0 || thickIn <= 0 || cement <= 0 || sand <= 0) throw ArgumentError('Inputs must be > 0.');
  final dry = areaSqft * thickIn / 12 * kMortarDryFactor;
  return Mix(dry * cement / (cement + sand) / kCftPerCementBag, dry * sand / (cement + sand), dry);
}

double excavationCft(double l, double w, double d, {double swellPct = 0}) {
  if (l <= 0 || w <= 0 || d <= 0) throw ArgumentError('Inputs must be > 0.');
  return l * w * d * (1 + swellPct / 100);
}

double tileCount(double areaSqft, double tileLIn, double tileWIn, double wastePct) {
  if (areaSqft <= 0 || tileLIn <= 0 || tileWIn <= 0) throw ArgumentError('Inputs must be > 0.');
  return (areaSqft * (1 + wastePct / 100) / (tileLIn * tileWIn / 144)).ceilToDouble();
}

class RoadResult {
  final double asphaltM3, asphaltTons, pipeLenFt, pipeJoints, manholes;
  RoadResult(this.asphaltM3, this.asphaltTons, this.pipeLenFt, this.pipeJoints, this.manholes);
}

/// Road length/width in ft, asphalt thickness in inches; one sewer line per [sewerLines].
RoadResult road(double lenFt, double widthFt, double thickIn,
    {double pipeJointFt = 8, double manholeSpacingFt = 150, int sewerLines = 1}) {
  if (lenFt <= 0 || widthFt <= 0 || thickIn <= 0) throw ArgumentError('Inputs must be > 0.');
  final m3 = lenFt * kFtToM * widthFt * kFtToM * thickIn * 0.0254;
  final pipe = lenFt * sewerLines;
  return RoadResult(m3, m3 * kAsphaltTonPerM3, pipe, (pipe / pipeJointFt).ceilToDouble(),
      ((lenFt / manholeSpacingFt).ceil() + 1) * sewerLines.toDouble());
}
