import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inventory_app/pages/main_page.dart';
import 'package:inventory_app/utils/utils.dart' as utils;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:inventory_app/globals.dart' as globals;


class OrderPage extends StatefulWidget {
  const OrderPage({super.key, required this.orderId});

  final String? orderId;

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  Map<String, dynamic> orderDetails = {};

  Future<List<Map<String, dynamic>>> _fetchOrder() async {
    // Fetch the order from the database
    final database = await openDatabase(
      path.join(await getDatabasesPath(), 'inventory_app.db'),
    );
    final order = await database.query(
      'orders',
      where: 'id = ?',
      whereArgs: [widget.orderId],
    );
    print(order);
    orderDetails = order[0];
    // Fetch the products in the order
    final List<Map<String, dynamic>> orderProducts = await database.query(
      'order_products',
      where: 'order_id = ?',
      whereArgs: [order[0]['id']],
    );
    print(orderProducts);
    final List<Map<String, dynamic>> products = [];
    for (final orderProduct in orderProducts) {
      final product_query = await database.query(
        'products',
        where: 'id = ?',
        whereArgs: [orderProduct['product_id']],
      );
      final product = Map<String, dynamic>.from(product_query[0]);
      // print('PRO DUCT$product');
      // for this page, we need to change the quantity to that of the product in the order
      product['quantity'] = orderProduct['quantity'];
      // and the unit price to that of the product in the order at the time of sale
      product['price'] = orderProduct['unit_price'];
      products.add(product);
      
    }
    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
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
            print(orderDetails);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order #${widget.orderId}'),
                      Text('${utils.formatTime(orderDetails['order_datetime'])}'),
                      Text('${utils.formatDate(orderDetails['order_datetime'])}'),
                      Text('Test: ${utils.dateToDescrptiveString(orderDetails['order_datetime'])}'),
                      if (globals.customerInfoFields && orderDetails['customer_name'] != null && orderDetails['customer_name'] != '') 
                       Text('Customer: ${orderDetails['customer_name']}'),
                      if (globals.customerInfoFields && orderDetails['customer_phone'] != null && orderDetails['customer_phone'] != '') 
                       Text('Customer Phone: ${orderDetails['customer_phone']}'),
                      
                      Text('Total: ${globals.currencySymbol}${orderDetails['total']}'),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      print(snapshot.data?[index]);
                      return ListTile(
                        leading: snapshot.data?[index]['image_path'] != null
                            ? Image.file(
                                File(snapshot.data?[index]['image_path']),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.image),
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
                                      'orders',
                                      where: 'id = ?',
                                      whereArgs: [widget.orderId],
                                    );
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(builder: (context) => const MainPage()),
                                      (route) => false,
                                    );
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
                            );
                          }
                        );
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete Order'),
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