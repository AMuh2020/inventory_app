import 'package:flutter/material.dart';
import 'package:inventory_app/components/product_list_tile.dart';
import 'package:inventory_app/models/product.dart';
import 'package:inventory_app/pages/add_product_page.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}


class _ProductsPageState extends State<ProductsPage> {

  Future <List<Product>>? productsListFuture;

  Future<List<Product>> getProducts() async {
    print('Getting products');
    // Open the database
    try {
      final database = await openDatabase(
        path.join(await getDatabasesPath(), 'inventory_app.db'),
      );

      final List<Map<String, dynamic>> products = await database.query('products');

      return List.generate(products.length, (index) {
        return Product(
          id: products[index]['id'],
          name: products[index]['name'],
          price: products[index]['price'],
          quantity: products[index]['quantity'],
          imagePath: products[index]['image_path'],
        );
      });
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }
  void onProductEdited() {
    print('Product edited! Refreshing products list');
    setState(() {
      productsListFuture = getProducts();
    });
  }

  @override
  void initState() {
    super.initState();
    productsListFuture = getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: FutureBuilder<List<Product>>(
            future: getProducts(),
            builder: (context, snapshot) {
              // if the connection is in progress, show a progress indicator else show the data
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return const Center(
                  child: Text('An error occurred while loading products'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No products found'),
                );
              }
              final products = snapshot.data!;

              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  print('Product: ${products[index].name}');
                  return ProductListTile(
                    product: products[index],
                    onProductEdited: onProductEdited,
                  );
                },
              );
            },
          ),
        ),
        ElevatedButton(
          onPressed: () {
            print('Add product button clicked!');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const AddProductPage();
                },
              ),
            ).then((_) {
              setState(() {
                productsListFuture = getProducts();
              });
            });
          },
          child: const Text('Add product'),
        ),
      ],
    );
  }
}