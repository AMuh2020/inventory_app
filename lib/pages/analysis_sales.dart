import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:inventory_app/utils/graph_utils.dart' as graph_utils;
import 'package:inventory_app/utils/date_utils.dart' as date_utils;
import 'package:intl/intl.dart';

class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);
}
final _monthDayFormat = DateFormat('dd-MM-yy');

class AnalysisSales extends StatefulWidget {
  const AnalysisSales({super.key});

  @override
  State<AnalysisSales> createState() => _AnalysisSalesState();
}

class _AnalysisSalesState extends State<AnalysisSales> {
  

final timeSeriesSales = [
  TimeSeriesSales(DateTime(2017, 9, 19), 5),
  TimeSeriesSales(DateTime(2017, 9, 26), 25),
  TimeSeriesSales(DateTime(2017, 10, 3), 100),
  TimeSeriesSales(DateTime(2017, 10, 10), 75),
  TimeSeriesSales(DateTime(2018, 10, 10), 30)
];
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text('Sales Analysis'),
            const Text('Coming soon...'),
          ],
        ),
      ),
    );
    return Column(
      children: [
        Text('Sales per day'),
        FutureBuilder(
          future: graph_utils.getSalesPerDayData(),
          builder: (context, snapshot) {
            print(snapshot.data);
            // print(date_utils.dateToMonthDay(snapshot.data![0]['date']));
            return SizedBox();
            return AspectRatio(
              aspectRatio: 2.0,
              child: Chart(
                data: snapshot.data ?? [],
                variables: {
                  'time': Variable(
                    accessor: (dynamic map) => date_utils.dateToDayMonthYear(map['date']),
                    scale: TimeScale(
                      formatter: (time) => '${time.month}/${time.day}',
                    ),
                  ),
                  'sales': Variable(
                    accessor: (dynamic map) => map['num_sales'] as num,
                  ),
                },
                marks: [
                  LineMark(
                    shape: ShapeEncode(value: BasicLineShape(dash: [5, 2])),
                    selected: {
                      'touchMove': {1}
                    },
                  )
                ],
                coord: RectCoord(color: const Color(0xffdddddd)),
                axes: [
                  Defaults.horizontalAxis,
                  Defaults.verticalAxis,
                ],
                selections: {
                  'touchMove': PointSelection(
                    on: {
                      GestureType.scaleUpdate,
                      GestureType.tapDown,
                      GestureType.longPressMoveUpdate
                    },
                    dim: Dim.x,
                  )
                },
                tooltip: TooltipGuide(
                  followPointer: [false, true],
                  align: Alignment.topLeft,
                  offset: const Offset(-20, -20),
                ),
                crosshair: CrosshairGuide(followPointer: [false, true]),
              ),
            );
          }
        ),
        Container(
                margin: const EdgeInsets.only(top: 10),
                width: 350,
                height: 300,
                child: Chart(
                  data: timeSeriesSales,
                  variables: {
                    'time': Variable(
                      accessor: (TimeSeriesSales datum) => datum.time,
                      scale: TimeScale(
                        formatter: (time) => _monthDayFormat.format(time),
                      ),
                    ),
                    'sales': Variable(
                      accessor: (TimeSeriesSales datum) => datum.sales,
                    ),
                  },
                  marks: [
                    LineMark(
                      shape: ShapeEncode(value: BasicLineShape(dash: [5, 2])),
                      selected: {
                        'touchMove': {1}
                      },
                    )
                  ],
                  coord: RectCoord(color: const Color(0xffdddddd)),
                  axes: [
                    Defaults.horizontalAxis,
                    Defaults.verticalAxis,
                  ],
                  selections: {
                    'touchMove': PointSelection(
                      on: {
                        GestureType.scaleUpdate,
                        GestureType.tapDown,
                        GestureType.longPressMoveUpdate
                      },
                      dim: Dim.x,
                    )
                  },
                  tooltip: TooltipGuide(
                    followPointer: [false, true],
                    align: Alignment.topLeft,
                    offset: const Offset(-20, -20),
                  ),
                  crosshair: CrosshairGuide(followPointer: [false, true]),
                ),
              ),
      ],
    );
  }
}