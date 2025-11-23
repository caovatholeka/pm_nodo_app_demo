import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/commons/app_colors.dart';

class CachedImageWidget extends StatelessWidget {
  String urlImage;
  CachedImageWidget({super.key, required this.urlImage});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
        fit: BoxFit.cover,
        progressIndicatorBuilder: (context, url, progress) {
          return Center(
              child: CircularProgressIndicator(
                value: progress.progress,
                valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.colorSuccess500),
              ));
        },
        useOldImageOnUrlChange: true,
        errorWidget: (context, url, error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 25,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  child: Text(
                    "error",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color:Colors.red,
                      fontWeight: FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                )
              ],
            ),
          );
        },
        imageUrl: urlImage,
        imageBuilder: (context, imageProvider) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          );
        });
  }
}
