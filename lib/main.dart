import 'package:flutter/material.dart';
import 'package:inventory_app/models/cart_item.dart';
import 'package:inventory_app/models/product.dart';
import 'package:inventory_app/pages/main_page.dart';
import 'package:inventory_app/themes/theme_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:inventory_app/utils/utils.dart' as utils;


// Future<void> requestPermissions() async {
//   // PermissionStatus status = await Permission.manageExternalStorage.status;
  
//   // print('Storage permission status: $status');
//   // if (status.isDenied || status.isPermanentlyDenied ) {
//   //   status = await Permission.manageExternalStorage.request();
//   //   print('Storage permission status2: $status');
//   // }

//   // if (!status.isGranted) {
//   //   // Handle the case where the permission is not granted
//   //   print('Storage permission denied');
//   // }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await requestPermissions();

  await utils.settingsStartUp();

  // utils.deleteDatabaseFile();
  // Open the database and store the reference.
  // ignore: unused_local_variable
  final database = openDatabase(
    // Set the path to the database. Note: Using the `join` function from the
    // `path` package is best practice to ensure the path is correctly
    // constructed for each platform.
    join(await getDatabasesPath(), 'inventory_app.db'),
    // When the database is first created, create a table to store products.
    onCreate: (db, version) {
      print('Creating the products table');
      db.execute(
        'CREATE TABLE products(id INTEGER PRIMARY KEY, name TEXT, price TEXT, quantity INTEGER, image_path TEXT, created_at TEXT, updated_at TEXT, is_visible BOOLEAN NOT NULL CHECK (is_visible IN (0, 1)) DEFAULT 1)',
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
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartModel()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()), // Add other providers here
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( 
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const MainPage(),
    );
  }
}



class CartModel extends ChangeNotifier {
  final List<CartItem> _cart = [];

  double get totalPrice => _cart.fold(0, (total, current) => total + double.parse(current.product.price) * current.quantity);

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  // check if the product is already in the cart
  CartItem? getCartItem(int productId) {
    for (final cartItem in _cart) {
      if (cartItem.product.id == productId) {
        return cartItem;
      }
    }
    return null;
  }

  void addProductToCart(Product product) {
    // Check if the product is already in the cart
    final cartItem = getCartItem(product.id);
    // If the product is not in the cart, add it
    if (cartItem == null) {
      print('Product not in cart');
      print(product.quantity);
      if (product.quantity == 0) {
        print('Product out of stock');
        print(_cart);
        return;
      }
      _cart.add(CartItem(product: product, quantity: 1));
    } else {
      // If the product is in the cart, increment the quantity
      cartItem.quantity++;
      if (cartItem.product.quantity < cartItem.quantity) {
        cartItem.quantity--;
      }
    }
    notifyListeners();
  }
  void decrementCartItemQuantity(CartItem cartItem) {
    cartItem.quantity--;
    if (cartItem.quantity == 0) {
      _cart.remove(cartItem);
    }
    notifyListeners();
  }
  void incrementCartItemQuantity(CartItem cartItem) {
    cartItem.quantity++;
    if (cartItem.product.quantity < cartItem.quantity) {
      cartItem.quantity--;
    }
    notifyListeners();
  }
  void removeCartItemFromCart(CartItem cartItem) {
    _cart.remove(cartItem);
    notifyListeners();
  }
  
  int getProductQuantity(Product product) {
    final cartItem = getCartItem(product.id);
    if (cartItem != null) {
      return cartItem.quantity;
    }
    return 0;
  }

  // Get the list of products in the cart
  List<CartItem> get products => _cart;
}
