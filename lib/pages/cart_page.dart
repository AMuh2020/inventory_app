import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inventory_app/main.dart';
import 'package:inventory_app/models/cart_item.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:inventory_app/globals.dart' as globals;

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
    List<CartItem> cart = Provider.of<CartModel>(context, listen: false).products;
    // For each product in the cart
    for (final cartItem in cart) {
      // Update the product quantity - decrement by the quantity in the cart
      await database.rawUpdate(
        'UPDATE products SET quantity = quantity - ? WHERE id = ?',
        [cartItem.quantity, cartItem.product.id],
      );
      print(cartItem.product);
      // Create a new order_products record - linking the order and product
      await database.insert(
        'order_products',
        <String, dynamic>{
          'order_id': order,
          'product_id': cartItem.product.id,
          'quantity': cartItem.quantity,
          'unit_price': cartItem.product.price,
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
        const Text(
          'Order Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Consumer<CartModel>(
            builder: (context, cart, child) {
              if (cart.products.isEmpty) {
                return const Center(
                  child: Text('No products in cart'),
                );
              }
              return ListView.builder(
                itemCount: cart.products.length,
                itemBuilder: (context, index) {
                  final cartItem = cart.products[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                          child: cartItem.product.imagePath.isNotEmpty ? Image.file(File(cartItem.product.imagePath)) : const Placeholder(),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${cartItem.product.name} ',
                                      style: const TextStyle(
                                        // fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ), 
                                    Text('Price: ${globals.currencySymbol}${double.parse(cartItem.product.price) * cartItem.quantity}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                cart.decrementCartItemQuantity(cartItem);
                              },
                            ),
                            Text('${cartItem.quantity}'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                cart.incrementCartItemQuantity(cartItem);
                              },
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            cart.removeCartItemFromCart(cartItem);
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
        globals.customerInfoFields ?
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _customerNameController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: 'Customer name',
                  ),
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                ),
                TextField(
                  controller: _customerPhoneNumberController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.phone),
                    labelText: 'Customer phone number',
                    hintText: '0712345678',
                  ),
                  onTapOutside: (event) => FocusScope.of(context).unfocus(),
                ),
              ],
            ),
          ) : const SizedBox.shrink(),
        
        Text(
          'Total: ${globals.currencySymbol}${Provider.of<CartModel>(context).totalPrice}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
    
        ElevatedButton(
          onPressed: () {
            print('Sell button clicked!');
            if (globals.customerInfoFields) {
              if (_customerNameController.text.isEmpty || _customerPhoneNumberController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter customer name and phone number'),
                  ),
                );
                return;
              }
            }
            if (Provider.of<CartModel>(context, listen: false).products.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please add products to cart'),
                ),
              );
              return;
            }
            _sellProducts();
          },
          child: const Text('Sell'),
        ),
      ],
    );
  }
}