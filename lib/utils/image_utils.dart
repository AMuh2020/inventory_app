import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;


Future<XFile?> selectImage() async {
  try {
    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    }
    return image;
  } catch (e) {
    print(e);
    return null;
  }
  
  }

  Future<XFile?> takeImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.camera);
      if (image == null) {
        return null;
      }
      return image;
    } catch (e) {
      print(e);
      return null;
  }
  }

  Future<String> saveImage(XFile? image) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    File imgFile = File(path.join(appDocDir.path, image!.name));
    imgFile.writeAsBytesSync(await image.readAsBytes());
    return imgFile.path;
  }