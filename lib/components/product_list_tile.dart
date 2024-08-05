import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inventory_app/main.dart';
import 'package:inventory_app/models/product.dart';
import 'package:inventory_app/pages/edit_product_page.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:inventory_app/globals.dart' as globals;

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
        child:  Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: product.imagePath.isNotEmpty 
                      ? Image.file(
                          File(product.imagePath),
                          // fit: BoxFit.cover,
                        ) 
                      : const Placeholder() // Or any other placeholder widget,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text('Item name: ${product.name}'),
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  // overflow: TextOverflow.ellipsis,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              Text(
                                'price: ${globals.currencySymbol}${product.price}',
                                style: Theme.of(context).textTheme.titleMedium
                              ),
                              Text(
                                'Quantity in stock: ${product.quantity}',
                                style: Theme.of(context).textTheme.titleSmall
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      badges.Badge(
                        showBadge: quantityInCart(context) > 0,
                        badgeStyle: badges.BadgeStyle(
                          badgeColor: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        badgeContent: Text('${quantityInCart(context)}'),
                        child: ElevatedButton(
                          onPressed: () {
                            print('Add to cart button clicked!');
                            Provider.of<CartModel>(context, listen: false).addProductToCart(product);
                          },
                          child: const Text('Add to cart'),
                        ),
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
      
    );
  }
}