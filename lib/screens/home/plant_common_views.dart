import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

OutlinedBorder plantBorder() {
  return const RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(10.0),
      bottomLeft: Radius.circular(10.0),
    ),
  );
}


//todo use some image loader plugin
Widget plantImage(String url) {
  return AspectRatio(
    aspectRatio: 7.0 / 4.0,
    child: ClipRRect(
      borderRadius: const BorderRadius.only(topRight: Radius.circular(10.0)),
      child: FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        image: url,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    ),
  );
}
