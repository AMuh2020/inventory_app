import 'package:flutter/material.dart';
import 'package:inventory_app/pages/sale_page.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:inventory_app/utils/date_utils.dart' as date_utils;

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {

  Future<List<Map<String, dynamic>>> getSales() async {
    print('Getting sales');
    // Open the database
    final database = await openDatabase(
      path.join(await getDatabasesPath(), 'inventory_app.db'),
    );

    final List<Map<String, dynamic>> sales = await database.query(
      'sales',
      orderBy: 'datetime DESC',
    );
    print(sales);
    await database.close();
    return List.generate(sales.length, (index) {
      return {
        'id': sales[index]['id'],
        'datetime': sales[index]['datetime'],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder(
            future: getSales(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Error fetching orders'),
                  );
                }
                if (snapshot.data?.isEmpty ?? true) {
                  return const Center(
                    child: Text('No sales found, start making sales to create sales'),
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
                            builder: (context) => SalePage(orderId: snapshot.data?[index]['id'].toString()),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text('Sale ID: #${snapshot.data?[index]['id']}'),
                        subtitle: Text('${date_utils.formatDateTime(snapshot.data?[index]['datetime'])}'),
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