import 'package:flutter/material.dart';
import 'package:inventory_app/models/cart_item.dart';
import 'package:inventory_app/models/product.dart';
import 'package:inventory_app/pages/main_page.dart';
import 'package:inventory_app/themes/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:inventory_app/utils/utils.dart' as utils;
import 'package:media_store_plus/media_store_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:inventory_app/globals.dart' as globals;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await requestPermissions();

  await utils.settingsStartUp();

  await MediaStore.ensureInitialized();
  // From API 33, we request photos, audio, videos permission to read these files. This the new way
  // From API 29, we request storage permission only to read access all files
  // API lower than 30, we request storage permission to read & write access access all files

  // For writing purpose, we are using [MediaStore] plugin. It will use MediaStore or java File based on API level.
  // It will use MediaStore for writing files from API level 30 or use java File lower than 30
  List<Permission> permissions = [
    Permission.storage,
  ];
  DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  final androidInfo = await deviceInfoPlugin.androidInfo;

  // android permissions
  if ((androidInfo.version.sdkInt) >= 33) {
    permissions.add(Permission.photos);
    permissions.add(Permission.audio);
    permissions.add(Permission.videos);
  }
  
  final status = await permissions.request();
  print(status);

  // You have set this otherwise it throws AppFolderNotSetException
  MediaStore.appFolder = "MediaStorePlugin";

  // utils.deleteDatabaseFile();
  // Open the database and store the reference.
  // ignore: unused_local_variable
  final database = await openDatabase(
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
        'CREATE TABLE sales(id INTEGER PRIMARY KEY, total TEXT, datetime TEXT, customer_name TEXT, customer_phone TEXT)',
      );
      db.execute(
        'CREATE TABLE sale_products (sale_id INTEGER, product_id INTEGER, quantity INTEGER, unit_price TEXT, PRIMARY KEY (sale_id, product_id), FOREIGN KEY (sale_id) REFERENCES sales(id) ON DELETE CASCADE, FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE)'
      );
    },
   
   // Set the version. This executes the onCreate function and provides a
   // path to perform database upgrades and downgrades.
    version: 2,
  );
  await database.close();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartModel()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => CurrencyProvider()),
        ChangeNotifierProvider(create: (context) => CustomerInfoProvider()),
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

class CurrencyProvider with ChangeNotifier {
  static final CurrencyProvider _instance = CurrencyProvider._internal();

  factory CurrencyProvider() {
    return _instance;
  }

  CurrencyProvider._internal();

  String _currencySymbol = '';

  String get currencySymbol => _currencySymbol;

  set currencySymbol(String value) {
    _currencySymbol = value;
    utils.saveSharedPref('currencySymbol', String, value);
    notifyListeners();
  }
}

class CustomerInfoProvider with ChangeNotifier {
  static final CustomerInfoProvider _instance = CustomerInfoProvider._internal();

  factory CustomerInfoProvider() {
    return _instance;
  }

  CustomerInfoProvider._internal();

  bool _customerInfoFields = false;

  bool get customerInfoFields => _customerInfoFields;

  set customerInfoFields(bool value) {
    _customerInfoFields = value;
    utils.saveSharedPref('customerInfoFields', bool, value);
    notifyListeners();
  }
}


class CartModel extends ChangeNotifier {
  final List<CartItem> _cart = [];

  String get totalPrice => calculateTotalPrice(_cart);

  String calculateTotalPrice(List<CartItem> cart) {
    double total = 0;
    for (final cartItem in cart) {
      total += double.parse(cartItem.product.price) * cartItem.quantity;
    }
    return total.toStringAsFixed(2);
  }

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
  int get totalCartItems => _cart.fold(0, (total, current) => total + current.quantity);

  // Get the list of products in the cart
  List<CartItem> get products => _cart;
}
