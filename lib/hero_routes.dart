import 'package:flutter/material.dart';
import 'package:icafeplay/gateway.dart' as gateway;

class ImageHero extends StatelessWidget {
  final String image_path;
  final int image_id;
  const ImageHero({super.key, required this.image_path, required this.image_id});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.9,
              child: Hero(
                tag: "image-$image_id",
                child: Center(
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 0.5,
                    maxScale: 2,
                    child: Image.network(
                      "${gateway.ENDPOINT}/$image_path",
                      fit: BoxFit.contain
                    ),
                  ),
                )
              )
            )
          ]
        )
      ),
    );
  }
}