// import 'package:inventory_app/models/product.dart';

// class Order {
//   final int id;
//   final List<Product> products;

//   Order({
//     required this.id,
//     required this.products, 
//   });

//   factory Order.fromMap(Map<String, dynamic> map) {
//     return Order(
//       id: map['id'],
//       products: List<Product>.from(map['products'].map((product) => Product.fromMap(product))),
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'products': products.map((product) => product.toMap()).toList(),
//     };
//   }
// }