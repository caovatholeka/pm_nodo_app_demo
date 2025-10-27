import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../logger/logger.dart';

class AttachFileHelper {
  AttachFileHelper._privateConstructor();

  static final AttachFileHelper shared = AttachFileHelper._privateConstructor();

  Future<File?> getImageFromLibrary() async {
    File? image;
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        image = File(pickedFile.path);
      } else {
        logger.d('No image selected.');
      }
    } on Exception catch (e) {
      String error = e.toString();
    }
    return image;
  }

  Future<File?> getPictureByCamera() async {
    var resultList = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );
    return File(resultList?.path ?? "");
  }

}