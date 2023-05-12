import 'individual_bar.dart';

class BarData {
  final double amount0;
  final double amount1;
  final double amount2;
  final double amount3;
  final double amount4;
  final double amount5;
  final double amount6;

  BarData({
    required this.amount0,
    required this.amount1,
    required this.amount2,
    required this.amount3,
    required this.amount4,
    required this.amount5,
    required this.amount6,
  });

  List<IndividualBar> barData = [];

  void initializeBarData() {
    barData = [
      IndividualBar(x: 0, y: amount0),
      IndividualBar(x: 1, y: amount1),
      IndividualBar(x: 2, y: amount2),
      IndividualBar(x: 3, y: amount3),
      IndividualBar(x: 4, y: amount4),
      IndividualBar(x: 5, y: amount5),
      IndividualBar(x: 6, y: amount6),
    ];
  }
}
