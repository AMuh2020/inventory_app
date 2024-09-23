import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:inventory_app/utils/date_utils.dart' as date_utils;

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
  return products;
  
}

Future<List<Map<String, dynamic>>> getSalesPerDayData() async {
  final database = await openDatabase(
    join(await getDatabasesPath(), 'inventory_app.db'),
  );
  final List<Map<String, dynamic>> sales = await database.query(
    'orders',
    columns: ['order_datetime'],
  );
  // count the number of sales per day
  final Map<String, int> salesPerDay = {};
  for (final sale in sales) {
    final date =  date_utils.dateToDayMonthYear(sale['order_datetime']);
    print(date);
    salesPerDay[date] = (salesPerDay[date] ?? 0) + 1;
  }
  print(salesPerDay);
  return salesPerDay.entries
      .map((entry) => {'date': entry.key, 'num_sales': entry.value})
      .toList();
}

