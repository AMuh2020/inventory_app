import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_app/models/product.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:inventory_app/utils/image_utils.dart' as imageUtils;

class ProductEditPage extends StatefulWidget {
  const ProductEditPage({super.key, required this.product});
  final Product product;

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _priceController = TextEditingController();

  final TextEditingController _quantityController = TextEditingController();

  // store the selected image future
  Future<XFile?>? selectedImageFuture;

  // store the path of the image
  String _imgPath = ''; 

  bool _isImageChanged = false;

  Future<void> _saveProduct() async {
    final name = _nameController.text;
    final price = _priceController.text;
    final quantity = int.parse(_quantityController.text);
    // String imgPath = '';

    if (_isImageChanged) {
      // save the image and get the path
      await imageUtils.saveImage(await selectedImageFuture).then((value) {
        // print('Image saved: $value');
        _imgPath = value;
      });
    }

    // Create a new product object with the updated values
    final product = Product(
      name: name,
      price: price,
      quantity: quantity,
      imagePath: _imgPath,
    );

    final database = await openDatabase(
      path.join(await getDatabasesPath(), 'inventory_app.db'),
    );

    await database.update(
      'products',
      product.toMapForDB(),
      where: 'id = ?',
      whereArgs: [widget.product.id],
    );
    
    print('Product saved!');
    Navigator.pop(context);
  }

  Future<void> _deleteProduct() async {
    final database = await openDatabase(
      path.join(await getDatabasesPath(), 'inventory_app.db'),
    );

    // get the product info
    // final product = await database.query(
    //   'products',
    //   where: 'id = ?',
    //   whereArgs: [widget.product.id],
    // );
    // if no row in order_products, has the product, delete the product
    final orderProducts = await database.query(
      'order_products',
      where: 'product_id = ?',
      whereArgs: [widget.product.id],
    );
    if (orderProducts.isNotEmpty) {
      print('Product is in an order, set visibility to false');
      await database.update(
        'products',
        <String, dynamic>{'is_visible': 0},
        where: 'id = ?',
        whereArgs: [widget.product.id],
      );
      Navigator.pop(context);
      return;
    }
    await database.delete(
      'products',
      where: 'id = ?',
      whereArgs: [widget.product.id],
    );
    
    print('Product deleted! (essentially, visibility set to false)');
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.product.name;
    _priceController.text = widget.product.price;
    _quantityController.text = widget.product.quantity.toString();
    _imgPath = widget.product.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // a button to select an image
              ElevatedButton.icon(
                onPressed: () {
                  // image add option dropdown
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('Camera'),
                            onTap: () {
                              setState(() {
                                selectedImageFuture = imageUtils.takeImage();
                                _isImageChanged = true;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo),
                            title: const Text('Gallery'),
                            onTap: () {
                              setState(() {
                                selectedImageFuture = imageUtils.selectImage();
                                _isImageChanged = true;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    }
                  );
                },
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Change Image'),
              ),
              FutureBuilder(
                future: selectedImageFuture,
                builder: (context, snapshot) {
                  // print(snapshot.data);
                  if (snapshot.connectionState == ConnectionState.done) {
                    return SizedBox(
                      height: 200,
                      width: 200,
                      child: Image.file(File(snapshot.data!.path)),
                    );
                  } else if (widget.product.imagePath.isNotEmpty) {
                    return SizedBox(
                      height: 200,
                      width: 200,
                      child: Image.file(File(widget.product.imagePath)),
                    );
                  } else {
                    return const Text('No image selected');
                  }
                },
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              ElevatedButton.icon(
                onPressed: () async { 
                  print('Save button clicked!');
                  await _saveProduct();
                },
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  print('Delete button clicked!');
                  _deleteProduct();
                },
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
              )
            ],
          ),
        ),
      ),
    );
  }
}