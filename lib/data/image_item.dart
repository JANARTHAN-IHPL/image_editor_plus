import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageItem {
  String title = "";
  int width = 300;
  int height = 300;
  Uint8List bytes = Uint8List.fromList([]);
  Completer loader = Completer();

  ImageItem([dynamic img]) {
    if (img != null) load(img);
  }

  Future load(dynamic imageFile, {String? describeTxt}) async {
    loader = Completer();

    if (imageFile is ImageItem) {
      title = describeTxt ?? "";
      height = imageFile.height;
      width = imageFile.width;
      bytes = imageFile.bytes;
      loader.complete(true);
    } else {
      title = describeTxt ?? "";
      bytes =
          imageFile is Uint8List ? imageFile : await imageFile.readAsBytes();
      var decodedImage = await decodeImageFromList(bytes);
      height = decodedImage.height;
      width = decodedImage.width;
      loader.complete(decodedImage);
    }

    return true;
  }

  static ImageItem fromJson(Map json) {
    var image = ImageItem(json['image']);
    image.title = json['title'];
    image.width = json['width'];
    image.height = json['height'];

    return image;
  }

  Map toJson() {
    return {
      'title': title,
      'height': height,
      'width': width,
      'bytes': bytes,
    };
  }
}
