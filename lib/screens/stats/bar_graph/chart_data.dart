import 'individual_point.dart';
import 'package:daily_organiser/database/databaseusage.dart';
import 'package:daily_organiser/database/statsmodel.dart';

class ChartData {
  final List<double> amounts;

  ChartData({
    required this.amounts,
  });

  List<IndividualPoint> chartData = [];

  void initializeChartData(int xAmount) async {
    for (int i = 1; i <= xAmount; i++) {
      chartData.add(IndividualPoint(x: i.toDouble(), y: amounts[i - 1]));
    }
  }
}
