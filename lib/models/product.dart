class Product {
  final int id;
  final String name;
  // final String description;
  final String price;
  int quantity;
  final String imagePath;

  Product({
    // -1 is used to indicate that the product has not been saved to the database
    this.id = -1,
    required this.name,
    // required this.description,
    required this.price,
    required this.quantity,
    required this.imagePath,
  });

  Map<String, Object?> toMapForDB() {
    return {
      // id isnt needed as it is autoincremented
      // 'id': id,
      'name': name,
      // 'description': description,
      'price': price,
      'quantity': quantity,
      'image_path': imagePath,
    };
  }

  @override
  String toString() {
    return 'Product{id: $id, name: $name, price: $price, quantity: $quantity, imagePath: $imagePath}';
  }
  
}