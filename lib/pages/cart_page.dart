import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inventory_app/main.dart';
import 'package:inventory_app/models/product.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {

  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerPhoneNumberController = TextEditingController();

  Future<void> _sellProducts() async {
    final database = await openDatabase(
      path.join(await getDatabasesPath(), 'inventory_app.db'),
    );

    // Create a new order
    final order = await database.insert(
      'orders',
      <String, dynamic>{
        'id': null,
        'order_datetime': DateTime.now().toIso8601String(),
        'customer_name': _customerNameController.text,
        'customer_phone': _customerPhoneNumberController.text,
        'total': Provider.of<CartModel>(context, listen: false).totalPrice,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // Get the products in the cart
    List<Product> products = Provider.of<CartModel>(context, listen: false).products;
    // For each product in the cart
    for (final product in products) {
      // Update the product quantity - decrement by the quantity in the cart
      await database.rawUpdate(
        'UPDATE products SET quantity = quantity - ? WHERE id = ?',
        [product.quantity, product.id],
      );
      // Create a new order_products record - linking the order and product
      await database.insert(
        'order_products',
        <String, dynamic>{
          'order_id': order,
          'product_id': product.id,
          'quantity': product.quantity,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // Clear the cart
    Provider.of<CartModel>(context, listen: false).clearCart();

    // clear the customer name and phone number
    _customerNameController.clear();
    _customerPhoneNumberController.clear();

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order placed!'),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerPhoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Order Summary'),
        Expanded(
          child: Consumer<CartModel>(
            builder: (context, cart, child) {
              return ListView.builder(
                itemCount: cart.products.length,
                itemBuilder: (context, index) {
                  final product = cart.products[index];
                  // return ListTile(
                  //   leading: SizedBox(
                  //     width: 50,
                  //     height: 50,
                  //     child: product.imagePath.isNotEmpty ? Image.file(File(product.imagePath)) : Placeholder(),
                  //   ),
                  //   title: Text('${product.name} ${product.quantity > 1 ? 'x${product.quantity}' : ''}'),
                  //   subtitle: Text('Price: ${product.price * product.quantity}'),
                  //   trailing: IconButton(
                  //     icon: const Icon(Icons.delete),
                  //     onPressed: () {
                  //       cart.removeProduct(product);
                  //     },
                  //   ),
                  // );
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: product.imagePath.isNotEmpty ? Image.file(File(product.imagePath)) : Placeholder(),
                        ),
                        SizedBox(width: 2),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${product.name} ${product.quantity > 1 ? 'x${product.quantity}' : ''}'),
                            Text('Price: ${double.parse(product.price) * product.quantity}'),
                          ],
                        ),
                        Spacer(),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                cart.decrementProductQuantity(product);
                              },
                            ),
                            Text('${product.quantity}'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                cart.incrementProductQuantity(product);
                              },
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            cart.removeProduct(product);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: _customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Customer name',
                ),
              ),
              TextField(
                controller: _customerPhoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Customer phone number',
                ),
              ),
            ],
          ),
        ),
        Text('Total: ${Provider.of<CartModel>(context).totalPrice}'),
    
        ElevatedButton(
          onPressed: () {
            print('Sell button clicked!');
            _sellProducts();
          },
          child: const Text('Sell'),
        ),
      ],
    );
  }
}