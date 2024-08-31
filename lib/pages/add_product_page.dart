import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inventory_app/models/product.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:inventory_app/utils/image_utils.dart' as imageUtils;

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  bool imageSelected = false;

  // store the selected image future
  Future<XFile?>? selectedImageFuture;

  Future<void> _saveProduct() async {
    final name = _nameController.text;
    final price = _priceController.text;
    final quantity = int.parse(_quantityController.text);
    String imgPath = '';
    if (imageSelected) {
      // save the image and get the path
      await imageUtils.saveImage(await selectedImageFuture).then((value) {
        // print('Image saved: $value');
        imgPath = value;
      });
    }
    
    print(imgPath);
    final product = Product(
      name: name,
      price: price,
      quantity: quantity,
      imagePath: imgPath,
    );

    final database = await openDatabase(
      path.join(await getDatabasesPath(), 'inventory_app.db'),
    );

    await database.insert(
      'products',  
      product.toMapForDB(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('Product saved!');
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // a button to add image
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
                                if (selectedImageFuture != null) {
                                  imageSelected = true;
                                }
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
                                if (selectedImageFuture != null) {
                                  imageSelected = true;
                                }
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
                label: const Text('Add Image'),
              ),
              FutureBuilder(
                future: selectedImageFuture,
                builder: (context, snapshot) {
                  // print(snapshot.data);
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data == null) {
                      return const Text('No image selected');
                    }
                    
                    return SizedBox(
                      height: 200,
                      width: 200,
                      child: Image.file(File(snapshot.data!.path)),
                    );
                  } else {
                    return const Text('No image selected');
                  }
                },
              ),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product name',
                  icon: Icon(Icons.shopping_bag),
                ),
              ),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  icon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  icon: Icon(Icons.inventory_2),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
              ),
              SizedBox(height: 10,),
              ElevatedButton.icon(
                onPressed: () {
                  print('Save button clicked!');
                  // input validation
                  if (_nameController.text.isEmpty || _priceController.text.isEmpty || _quantityController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all fields!'),
                      ),
                    );
                    return;
                  }
                  _saveProduct();
                },
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}