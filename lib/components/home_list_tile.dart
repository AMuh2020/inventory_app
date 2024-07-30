import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inventory_app/main.dart';
import 'package:inventory_app/models/product.dart';
import 'package:inventory_app/pages/product_edit_page.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;

class ProductListTile extends StatelessWidget {
  const ProductListTile({super.key, required this.product, required this.onProductEdited});

  final Product product;

  // Function to be called when a product is edited (callback)
  final void Function() onProductEdited;

  int quantityInCart(BuildContext context) {
    final cart = Provider.of<CartModel>(context);
    // get the quantity of the product using the product id
    return cart.getProductQuantity(product);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          print('Item ${product.name} clicked!');
        },
        child: badges.Badge(
          showBadge: quantityInCart(context) > 0,
          badgeContent: Text('${quantityInCart(context)}'),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: product.imagePath.isNotEmpty 
                          ? Image.file(
                              File(product.imagePath),
                              // fit: BoxFit.cover,
                            ) 
                          : Placeholder() // Or any other placeholder widget,
                      ),
                      SizedBox(width: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text('Item name: ${product.name}'),
                          Text(
                            '${product.name}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'price: ${product.price}',
                            style: Theme.of(context).textTheme.titleMedium
                          ),
                          Text(
                            'Quantity in stock: ${product.quantity}',
                            style: Theme.of(context).textTheme.titleSmall
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          print('Add to cart button clicked!');
                          Provider.of<CartModel>(context, listen: false).addProductToCart(product);
                        },
                        child: const Text('Add to cart'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          print('Edit button clicked!');
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return ProductEditPage(product: product);
                              },
                            ),
                          ).then((_) {
                            onProductEdited();
                            print('Product edited!');
                          }
                          );
                        },
                        label: const Text('Edit'),
                        icon: const Icon(Icons.edit),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}