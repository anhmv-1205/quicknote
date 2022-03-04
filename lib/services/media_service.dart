import 'package:bloc_flutter/services/exceptions.dart';
import 'package:image_picker/image_picker.dart';

import '../model/data_layer.dart';

class MediaService {
  final ImagePicker _imagePicker = ImagePicker();
  ImageModel? image;

  Future<ImageModel?> pickImageFromGallery() async {
    try {
      final _image = await _imagePicker.pickImage(source: ImageSource.gallery);
      final image = ImageModel(imagePath: _image!.path);
      return image;
    } catch (e) {
      throw ImageNotFoundException('Image not found');
    }
  }
}
