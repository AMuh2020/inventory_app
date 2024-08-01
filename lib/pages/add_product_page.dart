import 'dart:io';

import 'package:flutter/material.dart';
import 'package:inventory_app/models/product.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  // create an instance of ImagePicker
  final ImagePicker _picker = ImagePicker();

  // store the selected image future
  Future<XFile?>? selectedImageFuture;

  // store the path of the image
  String _imgPath = '';

  Future<void> _saveProduct(String imgPath) async {
    final name = _nameController.text;
    final price = _priceController.text;
    final quantity = int.parse(_quantityController.text);

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
  Future<XFile?> _selectImage(BuildContext context) async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    
    return image;
  }
  Future<void> _saveImage(BuildContext context, XFile? image) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    File imgFile = File(path.join(appDocDir.path, image!.name));
    imgFile.writeAsBytesSync(await image.readAsBytes());
    _imgPath = imgFile.path;
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
              // a button to select image
              ElevatedButton(
                onPressed: () async {
                  // select image from gallery, is temporary
                  // final image = await _picker.pickImage(source: ImageSource.gallery);
                  setState(() {
                    selectedImageFuture = _selectImage(context);
                  });
                  XFile? imageTemp = await selectedImageFuture;
                  if (imageTemp != null) {
                    _saveImage(context, imageTemp);
                  }
                  print(selectedImageFuture);
                },
                child: const Text('Select image'),
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
              ElevatedButton(
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
                  _saveProduct(_imgPath);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}