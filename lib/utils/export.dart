// TODO: Export orders to CSV
// having major issues writing to the downloads directory

// import 'dart:io';
// import 'package:csv/csv.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart' as path;
// // import 'package:path_provider/path_provider.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:android_intent_plus/android_intent.dart';
// import 'package:android_intent_plus/flag.dart';

// Future<Map<String, dynamic>> exportOrdersToCsv() async {
//   print('${await getExternalStorageDirectory()}');
//   try {
//     final database = await openDatabase(
//       path.join(await getDatabasesPath(), 'inventory_app.db'),
//     );

//     final orders = await database.query('orders');
//     final orderProducts = await database.query('order_products');
//     final products = await database.query('products');
//     final List<Map<String, dynamic>> ordersList = [];
//     for (final order in orders) {
//       final orderProductsList = orderProducts.where((element) => element['order_id'] == order['id']).toList();
//       final orderProductsMap = <String, dynamic>{};
//       for (final orderProduct in orderProductsList) {
//         final product = products.firstWhere((element) => element['id'] == orderProduct['product_id']);
//         orderProductsMap[product['name'] as String] = orderProduct['quantity'];
//       }
//       ordersList.add({
//         'order_id': order['id'],
//         'order_datetime': order['order_datetime'],
//         'customer_name': order['customer_name'],
//         'customer_phone': order['customer_phone'],
//         'total': order['total'],
//         'products': orderProductsMap,
//       });
//     }

//     final csv = ListToCsvConverter().convert(ordersList.map((order) => order.values.toList()).toList());
//     final String fileName = 'orders_${DateTime.now().toIso8601String()}.csv';
    
//     final bool permissionCheck = await checkStoragePermission();
//     if (permissionCheck) {
//       final result = saveCsvToDownloads(csv, fileName);
//       return result;
//     } else {
//       return {'path': null, 'success': false};
    
//     }
//   } catch (e) {
//     print('Failed to export orders: $e');
//     return {'path': null, 'success': false};
//   }
// }

// Future<bool> checkStoragePermission() async {
//   if (Platform.isAndroid){
//     final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//     final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//     if (androidInfo.version.sdkInt >= 33) {
//       return true;
//     }
//   }
//   final PermissionStatus status = await Permission.storage.status;
//   if (status.isGranted) {
//     return true;
//   } else {
//     return false;
//   }
// }

// Future<Map<String, dynamic>> saveCsvToDownloads(String csv, String fileName) async {
//   try {
    
//     final Directory? downloadsDirectory = await getDownloadsDirectory();
//     if (downloadsDirectory != null) {
//       // final String csvPath = '${downloadsDirectory.path}/$fileName';
//       final String csvPath = '/storage/emulated/0/Documents/$fileName';
//       if (Platform.isAndroid) {
//         final intent = AndroidIntent(
//           action: 'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
//           data: Uri.file(csvPath).toString(),
//         );
//         await intent.launch();
//       }
//       final File file = File(csvPath);
//       await file.writeAsString(csv);
//       print('Orders exported to $csvPath');
//       return {'path': csvPath, 'success': true};
//     } else {
//       print('Failed to get downloads directory');
//       return {'path': null, 'success': false};
//     }
//   } catch (e) {
//     print('Failed to save CSV to downloads: $e');
//     return {'path': null, 'success': false};
//   }
// }