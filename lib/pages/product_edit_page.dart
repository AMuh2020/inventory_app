import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inventory_app/models/product.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ProductEditPage extends StatefulWidget {
  ProductEditPage({super.key, required this.product});
  final Product product;

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {
  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _priceController = TextEditingController();

  final TextEditingController _quantityController = TextEditingController();

  // create an instance of ImagePicker
  final ImagePicker _picker = ImagePicker();

  // store the selected image future
  Future<XFile?>? selectedImageFuture;

  // store the path of the image
  String _imgPath = ''; 

  Future<XFile?> _selectImage(BuildContext context) async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      
    });
    return image;
  }

  Future<void> _saveImage(BuildContext context, XFile? image) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    File imgFile = File(path.join(appDocDir.path, image!.name));
    imgFile.writeAsBytesSync(await image.readAsBytes());
    _imgPath = imgFile.path;
  }

  Future<void> _saveProduct() async {
    final name = _nameController.text;
    final price = _priceController.text;
    final quantity = int.parse(_quantityController.text);
    print('$name, $price, $quantity');

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

    await database.delete(
      'products',
      where: 'id = ?',
      whereArgs: [widget.product.id],
    );
    print('Product deleted!');
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // a button to select an image
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  selectedImageFuture = _selectImage(context);
                });
                XFile? imageTemp = await selectedImageFuture;
                _saveImage(context, imageTemp);
              },
              child: const Text('Select Image'),
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
    );
  }
}