

// TODO: Reciept generation and printing

// test function to write empty csv file to downloads directory

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:inventory_app/utils/date_utils.dart' as date_utils;
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

// 
Future<String> exportOrdersToCsv() async {
  final database = await openDatabase(
      path.join(await getDatabasesPath(), 'inventory_app.db'),
    );

    final orders = await database.query('orders');
    final orderProducts = await database.query('order_products');
    final products = await database.query('products');
    final List<Map<String, dynamic>> ordersList = [];
    for (final order in orders) {
      final orderProductsList = orderProducts.where((element) => element['order_id'] == order['id']).toList();
      final orderProductsMap = <String, dynamic>{};
      for (final orderProduct in orderProductsList) {
        final product = products.firstWhere((element) => element['id'] == orderProduct['product_id']);
        orderProductsMap['Name: ${product['name']}'] = 'Quantity ${orderProduct['quantity']}}';
      }
      ordersList.add({
        'order_id': order['id'],
        'order_datetime': date_utils.formatDateTime(order['order_datetime'].toString()),
        'customer_name': order['customer_name'] ?? 'N/A',
        'customer_phone': order['customer_phone'] ?? 'N/A',
        'total': order['total'],
        'products': orderProductsMap,
      });
    }
    
    return 'order_id,order_datetime,customer_name,customer_phone,total,products\n' 
    + ListToCsvConverter().convert(ordersList.map((order) => order.values.toList()).toList());
}

// Test function to write empty CSV file to downloads directory
Future<void> writeOrdersCsv() async {
  // fix 
  bool permissionGrant = false;
  if (Platform.isAndroid) {
    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
      permissionGrant = await Permission.photos.request().isGranted &&
          await Permission.audio.request().isGranted &&
          await Permission.videos.request().isGranted;
    } else {
      permissionGrant = await Permission.manageExternalStorage.request().isGranted;
    }
    
  } else {
    permissionGrant = await Permission.storage.request().isGranted;
  }

  if (true || await Permission.storage.request().isGranted) {
    final String csv = await exportOrdersToCsv();
    final String fileName = 'orders_${DateTime.now().toIso8601String()}.csv';
    // save file in downloads directory as temp file
    final Directory? downloadsDirectory = await getDownloadsDirectory();
    if (downloadsDirectory != null) {
      final String csvPath = '${downloadsDirectory.path}/$fileName';
      final File file = File(csvPath);
      await file.writeAsString(csv);
      print('Empty CSV file written to $csvPath');
      // then write using media store
      final MediaStore mediaStore = MediaStore();
      final mediaPath = await mediaStore.saveFile(
        tempFilePath: csvPath,
        dirType: DirType.download,
        dirName: DirName.download,
        relativePath: fileName,
      );
      print('CSV file written to $mediaPath');
      print(mediaPath);
    } else {
      print('Failed to get downloads directory');
    }
  } else {
    print('Storage permission denied');
  }
}

Future<Directory?> getDownloadsDirectory2() async {
  if (Platform.isAndroid) {
    return Directory('/storage/emulated/0/Download');
  } else {
    return await getDownloadsDirectory();
  }
}

// Future<void> exportOrdersToCsv() async {
//   print('Exporting orders to CSV');
//   final database = await openDatabase(
//     path.join(await getDatabasesPath(), 'inventory_app.db'),
//   );
//   final orders = await database.query('orders');
//   final orderProducts = await database.query('order_products');
//   final products = await database.query('products');
//   final List<Map<String, dynamic>> ordersList = [];
//   for (final order in orders) {
//     final orderProductsList = orderProducts.where((element) => element['order_id'] == order['id']).toList();
//     final orderProductsMap = <String, dynamic>{};
//     for (final orderProduct in orderProductsList) {
//       final product = products.firstWhere((element) => element['id'] == orderProduct['product_id']);
//       orderProductsMap[product['name'] as String] = orderProduct['quantity'];
//     }
//     ordersList.add({
//       'order_id': order['id'],
//       'order_datetime': order['order_datetime'],
//       'customer_name': order['customer_name'],
//       'customer_phone': order['customer_phone'],
//       'total': order['total'],
//       'products': orderProductsMap,
//     });
//   }
//   final csv = ListToCsvConverter().convert(ordersList.map((order) => order.values.toList()).toList());
//   final String fileName = 'orders_${DateTime.now().toIso8601String()}.csv';
//   final Directory? downloadsDirectory = await getDownloadsDirectory();
//   if (downloadsDirectory != null) {
//     final String csvPath = '${downloadsDirectory.path}/$fileName';
//     final File file = File(csvPath);
//     await file.writeAsString(csv);
//     print('Orders exported to $csvPath');
//   } else {
//     print('Failed to get downloads directory');
//   }
// }