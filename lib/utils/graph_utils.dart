import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<List<Map<String, dynamic>>> getProductsQuantityData() async {
  final database = await openDatabase(
    join(await getDatabasesPath(), 'inventory_app.db'),
  );

  final List<Map<String, dynamic>> products = await database.query(
    'products',
    columns: ['name', 'quantity'],
  );
  print(products);
  print('hello1');
  print(products.length);
  // return products;
  // return bar chart rod data
  // List<BarChartGroupData> barGroups = [];
  // for (int i = 0; i < products.length; i++) {
  //   print(i);
  //   barGroups.add(
  //     BarChartGroupData(
  //       x: i,
  //       barRods: [
  //         BarChartRodData(
  //           toY: double.parse(products[i]['quantity'].toString()),
  //           color: Colors.blue,
  //         ),
  //       ],
  //     )
  //   );
  //   print(barGroups);
  // }
  // print('hello');
  // print(barGroups);
  // // await database.close();
  // return barGroups;
  return products;
  
}