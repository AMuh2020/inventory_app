import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:inventory_app/utils/graph_utils.dart' as graphUtils;

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: Center(
        child: Column(
          children: [
            // stats
            // total products sold + breakdown of top 5 products sold
            // total revenue + breakdown of top 5 products by revenue
            // total profit + breakdown of top 5 products by profit
            // total sales text widget
            // FutureBuilder(
            //   future: graphUtils.getTotalSales(),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState != ConnectionState.done) {
            //       return const CircularProgressIndicator();
            //     }
            //     double totalSales = snapshot.data ?? 0;
            //     return Text('Total Sales: $totalSales');
            //   }
            // ),
            // sales per x graph - dropdown to choose x (day, week, month, year)
            // stock history graph - dropdown to choose x dropdown (product) dropdown (day, week, month, year)
            // sales per product graph - dropdwon (product, or maybe multiple line graph) dropdown to choose x (day, week, month, year)
            
            

            // SizedBox(height: 30,),
             AspectRatio(
              aspectRatio: 2.0,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 1),
                        FlSpot(1, 3),
                        FlSpot(2, 2),
                        FlSpot(3, 4),
                        FlSpot(4, 3),
                        FlSpot(5, 5),
                        FlSpot(6, 6),
                      ],
                    ),
                  ]
                  // read about it in the LineChartData section
                ),
                // duration: Duration(milliseconds: 150), // Optional
                // curve: Curves.linear, // Optional
              ),
            ),
            AspectRatio(
              aspectRatio: 2.0,
              child: BarChart(
                  BarChartData(
                    barGroups: [
                      BarChartGroupData(
                        x: 0,
                        barRods: [
                          BarChartRodData(toY: 1),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(toY: 3),
                        ],
                      ),
                      BarChartGroupData(
                        x: 2,
                        barRods: [
                          BarChartRodData(toY: 2),
                        ],
                      ),
                      BarChartGroupData(
                        x: 1,
                        barRods: [
                          BarChartRodData(toY: 4),
                        ],
                      ),
                      BarChartGroupData(
                        x: 4,
                        barRods: [
                          BarChartRodData(toY: 3),
                        ],
                      ),
                      BarChartGroupData(
                        x: 5,
                        barRods: [
                          BarChartRodData(toY: 5),
                        ],
                      ),
                      BarChartGroupData(
                        x: 6,
                        barRods: [
                          BarChartRodData(toY: 6),
                        ],
                      ),
                    ],
                    // read about it in the BarChartData section
                  )
                )
            ),
            SizedBox(height: 30,),
            FutureBuilder(
              future: graphUtils.getProductsQuantityData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const CircularProgressIndicator();
                }
                List<Map<String, dynamic>> products = snapshot.data ?? [];
                  return AspectRatio(
                    aspectRatio: 2.0,
                    child: BarChart(
                      BarChartData(
                        barGroups: products.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, dynamic> product = entry.value;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                borderRadius: BorderRadius.zero,
                                width: 22,
                                toY: double.parse(product['quantity'].toString()),
                                color: Colors.blue,
                              ),
                            ],
                          );
                        }).toList(),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                          sideTitles:  SideTitles(
                            reservedSize: 30,
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta titleMeta) {
                              int index = value.toInt();
                              if (index >= 0 && index < products.length) {
                                return SideTitleWidget(
                                  axisSide: titleMeta.axisSide,
                                  angle: pi * -0.3,
                                  child: Text(products[index]['name']),
                                );
                              } else {
                                return SideTitleWidget(
                                  axisSide: titleMeta.axisSide,
                                  child: Text(''),
                                );
                              }
                            },
                          ),
                          )
                        ),
                        alignment: BarChartAlignment.spaceAround,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            // tooltipBgColor: Colors.blueGrey,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                rod.toY.toString(),
                                TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                }
            ),
            SizedBox(height: 30,),
            // AspectRatio(
            // aspectRatio: 2.0,
            // child: BarChart(
            //     BarChartData(
            //       barGroups: await graphUtils.getProductsQuantityData(),
            //       // read about it in the BarChartData section
            //     )
            //   )
            // ),
          ],
        ),
      ),
    );
  }
}