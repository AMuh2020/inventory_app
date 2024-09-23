import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inventory_app/pages/main_page.dart';
import 'package:inventory_app/utils/date_utils.dart' as date_utils;
import 'package:inventory_app/utils/utils.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:inventory_app/main.dart';


class SalePage extends StatefulWidget {
  const SalePage({super.key, required this.orderId});

  final String? orderId;

  @override
  State<SalePage> createState() => _OrderPageState();
}

class _OrderPageState extends State<SalePage> {
  Map<String, dynamic> saleDetails = {};

  Future<List<Map<String, dynamic>>> _fetchOrder() async {
    // Fetch the order from the database
    final database = await openDatabase(
      path.join(await getDatabasesPath(), 'inventory_app.db'),
    );
    final sale = await database.query(
      'sales',
      where: 'id = ?',
      whereArgs: [widget.orderId],
    );
    print(sale);
    saleDetails = sale[0];
    // Fetch the products in the order
    final List<Map<String, dynamic>> saleProducts = await database.query(
      'sale_products',
      where: 'sale_id = ?',
      whereArgs: [sale[0]['id']],
    );
    print(saleProducts);
    final List<Map<String, dynamic>> products = [];
    for (final saleProduct in saleProducts) {
      final product_query = await database.query(
        'products',
        where: 'id = ?',
        whereArgs: [saleProduct['product_id']],
      );
      print(product_query);
      final product = Map<String, dynamic>.from(product_query[0]);
      // print('PRO DUCT$product');
      // for this page, we need to change the quantity to that of the product in the sale
      product['quantity'] = saleProduct['quantity'];
      // and the unit price to that of the product in the sale at the time of sale
      product['price'] = saleProduct['unit_price'];
      products.add(product);
      
    }
    await database.close();
    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sale Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FutureBuilder(
        future: _fetchOrder(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            print(saleDetails);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sale #${widget.orderId}'),
                      Text('${date_utils.formatTime(saleDetails['datetime'])}'),
                      Text('${date_utils.formatDate(saleDetails['datetime'])}'),
                      Text('Date: ${date_utils.dateToDescrptiveString(saleDetails['datetime'])}'),
                      if (CustomerInfoProvider().customerInfoFields && saleDetails['customer_name'] != null && saleDetails['customer_name'] != '') 
                       Text('Customer: ${saleDetails['customer_name']}'),
                      if (CustomerInfoProvider().customerInfoFields && saleDetails['customer_phone'] != null && saleDetails['customer_phone'] != '') 
                       Text('Customer Phone: ${saleDetails['customer_phone']}'),
                      
                      Text('Total: ${Provider.of<CurrencyProvider>(context).currencySymbol}${saleDetails['total']}'),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      print(snapshot.data?[index]);
                      return ListTile(
                        leading: (snapshot.data?[index]['image_path'] != null && snapshot.data?[index]['image_path'] != '')
                            ? Image.file(
                                File(snapshot.data?[index]['image_path']),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : SizedBox(height: 50,width: 50, child: const Icon(Icons.image)),
                        title: Text('Product: ${snapshot.data?[index]['name']}'),
                        subtitle: Text('Unit Price: ${snapshot.data?[index]['price']}, Quantity: ${snapshot.data?[index]['quantity']}'),
                      );
                    },
                  ),
                ),
                // generate a receipt
                // ElevatedButton.icon(
                //   onPressed: () {
                //     print('Print receipt button clicked!');
                //   },
                //   icon: const Icon(Icons.print),
                //   label: const Text('Print Receipt'),
                // ),
                
                // delete order
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Delete Order'),
                              content: const Text('Are you sure you want to delete this order? This action cannot be undone.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final database = await openDatabase(
                                      path.join(await getDatabasesPath(), 'inventory_app.db'),
                                    );
                                    await database.delete(
                                      'sales',
                                      where: 'id = ?',
                                      whereArgs: [widget.orderId],
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                      content: Text('Sale deleted successfully'),
                                    ));
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => const MainPage()),
                                      (route) => false,
                                    );
                                    await database.close();
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          }
                        );
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete Sale'),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}