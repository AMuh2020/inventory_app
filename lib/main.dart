import 'package:flutter/material.dart';
import 'package:inventory_app/models/product.dart';
import 'package:inventory_app/pages/main_page.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> deleteDatabaseFile() async {
  // Get the path to the database directory
  final dbPath = await getDatabasesPath();
  // Combine the directory path with the database name to get the full path
  final path = join(dbPath, 'inventory_app.db');

  // Delete the database file
  await deleteDatabase(path);
}

Future<void> requestPermissions() async {
  // PermissionStatus status = await Permission.manageExternalStorage.status;
  
  // print('Storage permission status: $status');
  // if (status.isDenied || status.isPermanentlyDenied ) {
  //   status = await Permission.manageExternalStorage.request();
  //   print('Storage permission status2: $status');
  // }

  // if (!status.isGranted) {
  //   // Handle the case where the permission is not granted
  //   print('Storage permission denied');
  // }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await requestPermissions(); b 

  // deleteDatabaseFile();
  // Open the database and store the reference.
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'inventory_app.db'),
    // When the database is first created, create a table to store products.
    onCreate: (db, version) {
      print('Creating the products table');
      db.execute(
        'CREATE TABLE products(id INTEGER PRIMARY KEY, name TEXT, price TEXT, quantity INTEGER, image_path TEXT)',
      );
      db.execute(
        'CREATE TABLE orders(id INTEGER PRIMARY KEY, total TEXT, order_datetime TEXT, customer_name TEXT, customer_phone TEXT)',
      );
      db.execute(
        'CREATE TABLE order_products (order_id INTEGER, product_id INTEGER, quantity INTEGER, PRIMARY KEY (order_id, product_id), FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE, FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE)'
      );
    },
   
   // Set the version. This executes the onCreate function and provides a
   // path to perform database upgrades and downgrades.
    version: 1,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartModel(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( 
      theme: ThemeData(
        
      ),
      home: const MainPage(),
    );
  }
}



class CartModel extends ChangeNotifier {
  final List<Product> _products = [];

  double get totalPrice => _products.fold(0, (total, current) => total + double.parse(current.price) * current.quantity);

  // Check if a product is already in the cart - helper function for addProduct
  List isProductInCart(Product product) {
    for (var item in _products) {
      if (item.id == product.id) {
        return [true, _products.indexOf(item)];
      }
    }
    return [false, null];
  }

  // Add a product to the cart
  void addProduct(Product product) {
    // if a product with the same id is already in the cart, increment its quantity
    if (isProductInCart(product)[0]) {
      print('Product already in cart, incrementing quantity');
      _products[isProductInCart(product)[1]].quantity += 1;
    } else {
      _products.add(product);
    }
    notifyListeners();
  }

  // Increment the quantity of a product in the cart
  void incrementProductQuantity(Product product) {
    _products[isProductInCart(product)[1]].quantity += 1;
    notifyListeners();
  }

  // Decrement the quantity of a product in the cart
  void decrementProductQuantity(Product product) {
    if (_products[isProductInCart(product)[1]].quantity > 1) {
      _products[isProductInCart(product)[1]].quantity -= 1;
    } else {
      removeProduct(product);
    }
    notifyListeners();
  }

  // Remove a product from the cart
  void removeProduct(Product product) {
    _products.remove(product);
    notifyListeners();
  }

  // Clear the cart
  void clearCart() {
    _products.clear();
    notifyListeners();
  }

  // Get the quantity of a product in the cart
  int getProductQuantity(int id) {
    for (var item in _products) {
      if (item.id == id) {
        return item.quantity;
      }
    }
    return 0;
  }

  // Get the list of products in the cart
  List<Product> get products => _products;
}
