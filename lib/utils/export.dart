

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

    final sales = await database.query('sales');
    final saleProductData = await database.query('sale_products');
    final products = await database.query('products');
    final List<Map<String, dynamic>> outList = [];
    for (final sale in sales) {
      final saleProductsList = saleProductData.where((element) => element['sale_id'] == sale['id']).toList();
      final saleProductsMap = <String, dynamic>{};
      for (final saleProduct in saleProductsList) {
        final product = products.firstWhere((element) => element['id'] == saleProduct['product_id']);
        saleProductsMap['Name: ${product['name']}'] = 'Quantity ${saleProduct['quantity']}}';
        outList.add({
          'sale_id': sale['id'],
          'product_id': saleProduct['product_id'],
          'product_name': product['name'],
          'quantity': saleProduct['quantity'],
          'unit_price': saleProduct['unit_price'],
          'subtotal': (saleProduct['quantity']as int) * double.parse(saleProduct['unit_price'] as String),
          'customer_name': sale['customer_name'],
          'customer_phone': sale['customer_phone'],
          'datetime': date_utils.formatDateTime(sale['datetime'].toString()),
        });
      }
      
    }
    await database.close();
    return 'Sale ID,Product ID,Product Name,Quantity,Unit Price,Subtotal,Customer Name,Customer Phone,Datetime\n'
    + ListToCsvConverter().convert(outList.map((product) => product.values.toList()).toList());
}

// Test function to write empty CSV file to downloads directory
Future<String> writeOrdersCsv() async {
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

  if (permissionGrant) {
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
      return mediaPath.toString();
    } else {
      print('Failed to get downloads directory');
      return '';
    }
  } else {
    print('Storage permission denied');
    return '';
  }
}

Future<Directory?> getDownloadsDirectory2() async {
  if (Platform.isAndroid) {
    return Directory('/storage/emulated/0/Download');
  } else {
    return await getDownloadsDirectory();
  }
}