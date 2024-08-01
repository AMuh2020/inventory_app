import 'package:flutter/material.dart';
import 'package:inventory_app/pages/order_page.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:inventory_app/utils/utils.dart' as utils;

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {

  Future<List<Map<String, dynamic>>> getOrders() async {
    print('Getting orders');
    // Open the database
    final database = await openDatabase(
      path.join(await getDatabasesPath(), 'inventory_app.db'),
    );

    final List<Map<String, dynamic>> orders = await database.query(
      'orders',
      orderBy: 'order_datetime DESC',
    );
    print(orders);
    
    return List.generate(orders.length, (index) {
      return {
        'id': orders[index]['id'],
        'datetime': orders[index]['order_datetime'],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder(
            future: getOrders(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error fetching orders'),
                  );
                }
                if (snapshot.data?.isEmpty ?? true) {
                  return const Center(
                    child: Text('No orders found, start making sales to create orders'),
                  );
                }
                return ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderPage(orderId: snapshot.data?[index]['id'].toString()),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text('Order #${snapshot.data?[index]['id']}'),
                        subtitle: Text('${utils.formatDateTime(snapshot.data?[index]['datetime'])}'),
                        trailing: const Icon(Icons.arrow_forward ),
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        )
      ],
    );
  }
}