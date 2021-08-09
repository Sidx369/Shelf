import 'package:flutter/material.dart';

class ImageFullScreen extends StatelessWidget {
  final String url;
  ImageFullScreen(this.url);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black,
        child: FadeInImage.assetNetwork(
          image: url,
          placeholder: 'assets/placeholder1.png',
          fit: BoxFit.contain,
        ));
  }
}
