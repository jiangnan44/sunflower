import 'package:flutter/material.dart';

OutlinedBorder plantBorder() {
  return const RoundedRectangleBorder(
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(10.0),
      bottomLeft: Radius.circular(10.0),
    ),
  );
}

Widget plantImage(String url) {
  return AspectRatio(
    aspectRatio: 7.0 / 4.0,
    child: ClipRRect(
      borderRadius: const BorderRadius.only(topRight: Radius.circular(10.0)),
      child: Image.network(
        url,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    ),
  );
}
