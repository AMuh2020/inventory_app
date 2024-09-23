import 'package:flutter/material.dart';
import 'package:inventory_app/utils/graph_utils.dart' as graph_utils;
import 'package:graphic/graphic.dart';

class AnalyticsProduct extends StatefulWidget {
  const AnalyticsProduct({super.key});

  @override
  State<AnalyticsProduct> createState() => _AnalyticsProductState();
}

class _AnalyticsProductState extends State<AnalyticsProduct> {

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // 
              SizedBox(height: 30,),
              
              Text('Products Quantity'),
              FutureBuilder(
                future: graph_utils.getProductsQuantityData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const CircularProgressIndicator();
                  }
                  return AspectRatio(
                    aspectRatio: 2.0,
                    child: Chart(
                      data: snapshot.data ?? [],
                      variables: {
                        'name': Variable(
                          accessor: (dynamic map) {
                            String name = map['name'] as String;
                            return name.split(' ').join('\n');
                          },
                        ),
                        'quantity': Variable(
                          accessor: (dynamic map) => map['quantity'] as num,
                        ),
                      },
                      axes: [
                        Defaults.horizontalAxis,
                        Defaults.verticalAxis,
                      ],
                      marks: [
                          IntervalMark(
                            label: LabelEncode(
                                encoder: (tuple) => Label(
                                  tuple['quantity'].toString(),
                                )
                              ),
                            elevation: ElevationEncode(value: 0, updaters: {
                              'tap': {true: (_) => 5}
                            }),
                            color:
                                ColorEncode(value: theme.primaryColor, updaters: {
                              'tap': {false: (color) => color.withAlpha(100)}
                            }),
                          )
                        ],
                    ),
                  );
                }
              ),
              // AspectRatio(
              //   aspectRatio: 2.0,
              //   child: Chart(
              //     data: [
              //       {'product': 'Product 1', 'quantity': 10},
              //       {'product': 'Product 2', 'quantity': 20},
              //       {'product': 'Product 3', 'quantity': 30},
              //       {'product': 'Product 4', 'quantity': 40},
              //       {'product': 'Product 5', 'quantity': 50},
              //     ],
              //     variables: {
              //       'product': Variable(
              //         accessor: (Map map) => map['product'] as String,
              //       ),
              //       'quantity': Variable(
              //         accessor: (Map map) => map['quantity'] as num,
              //       ),
              //     },
              //     axes: [
              //       Defaults.horizontalAxis,
              //       Defaults.verticalAxis,
              //     ],
              //     marks: [
              //         IntervalMark(
              //           label: LabelEncode(
              //               encoder: (tuple) => Label(tuple['quantity'].toString())),
              //           elevation: ElevationEncode(value: 0, updaters: {
              //             'tap': {true: (_) => 5}
              //           }),
              //           color:
              //               ColorEncode(value: Defaults.primaryColor, updaters: {
              //             'tap': {false: (color) => color.withAlpha(100)}
              //           }),
              //         )
              //       ],
              //   ),
              // ),
            ],
          ),
        ),
      );
  }
}