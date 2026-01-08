import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProjectBarChartCard extends StatelessWidget {
  const ProjectBarChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final data = [
      _Data('Mayhome', 80),
      _Data('VTS', 70),
      _Data('Phil Node', 65),
      _Data('iHouzz', 20),
    ];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Header(title: 'Báo mẫu dự án (%)', trailing: 'Tháng 12/2025'),
          SizedBox(
            height: 180,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              primaryYAxis: NumericAxis(minimum: 0, maximum: 100),
              series: [
                ColumnSeries<_Data, String>(
                  dataSource: data,
                  xValueMapper: (d, _) => d.name,
                  yValueMapper: (d, _) => d.value,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: TextButton(onPressed: () {}, child: Text('Xem chi tiết')),
          )
        ],
      ),
    );
  }
}

class _Data {
  final String name;
  final double value;
  _Data(this.name, this.value);
}

class _Header extends StatelessWidget {
  final String title;
  final String trailing;
  const _Header({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
        Text(trailing, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: child,
    );
  }
}
