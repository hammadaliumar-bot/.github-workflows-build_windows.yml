import 'constants.dart';

class BrickworkResult {
  final double wallVolCft, bricks, wetMortarCft, dryMortarCft, cementBags, sandCft;
  final double brickCost, cementCost, sandCost, totalCost;
  BrickworkResult(this.wallVolCft, this.bricks, this.wetMortarCft, this.dryMortarCft,
      this.cementBags, this.sandCft, this.brickCost, this.cementCost, this.sandCost)
      : totalCost = brickCost + cementCost + sandCost;
}

/// Wall L,H in ft; thickness, brick size & joint in inches (std brick 9 x 4.5 x 3).
BrickworkResult brickwork({
  required double lenFt, required double heightFt, required double thickIn,
  double bL = 9, double bW = 4.5, double bH = 3, double jointIn = 0.5,
  double cement = 1, double sand = 4,
  double ratePer1000Bricks = 0, double rateCementBag = 0, double rateSandCft = 0,
}) {
  if ([lenFt, heightFt, thickIn, bL, bW, bH, cement, sand].any((x) => x <= 0)) {
    throw ArgumentError('All dimensions and ratio parts must be > 0.');
  }
  final wallVol = lenFt * heightFt * thickIn / 12;
  final withJoint = (bL + jointIn) * (bW + jointIn) * (bH + jointIn) / 1728;
  final bricks = wallVol / withJoint;
  final wet = wallVol - bricks * (bL * bW * bH / 1728);
  final dry = wet * kMortarDryFactor;
  final bags = dry * cement / (cement + sand) / kCftPerCementBag;
  final sandCft = dry * sand / (cement + sand);
  return BrickworkResult(wallVol, bricks, wet, dry, bags, sandCft,
      bricks / 1000 * ratePer1000Bricks, bags * rateCementBag, sandCft * rateSandCft);
}

class ConcreteResult {
  final double wetCft, dryCft, cementBags, sandCft, crushCft, waterLiters;
  ConcreteResult(this.wetCft, this.dryCft, this.cementBags, this.sandCft, this.crushCft, this.waterLiters);
}

/// Water = bags x 50 kg x w/c ratio (litres).
ConcreteResult concrete({required double wetVolCft, double c = 1, double s = 2, double a = 4, double wc = 0.5}) {
  if ([wetVolCft, c, s, a].any((x) => x <= 0)) throw ArgumentError('Inputs must be > 0.');
  final dry = wetVolCft * kConcreteDryFactor;
  final sum = c + s + a;
  final bags = dry * c / sum / kCftPerCementBag;
  return ConcreteResult(wetVolCft, dry, bags, dry * s / sum, dry * a / sum, bags * 50 * wc);
}
