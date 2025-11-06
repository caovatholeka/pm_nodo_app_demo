import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pm_app/app/core/logger/logger.dart';

import '../../core/commons/app_assets.dart';
import '../../core/commons/app_colors.dart';
import '../../core/utils/utils.dart';

class AppCacheImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;

  const AppCacheImage({super.key, 
    required this.url,
    this.width,
    this.height,
    this.borderRadius = 0,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    bool isValidUrl = Uri.tryParse(url)?.isAbsolute == true;

    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: isValidUrl
          ? ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: url.isEmpty
            ? Container()
            : CachedNetworkImage(
          imageUrl: url,
          progressIndicatorBuilder:
              (context, url, downloadProgress) {
            return Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  value: downloadProgress.progress,
                  backgroundColor: Colors.white,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.themePrimaryDefault),
                ),
              ),
            );
          },
          errorWidget: (context, url, error) {
            return const Icon(
              Icons.image_outlined,
              color: Colors.white,
              size: 24,
            );
          },
          fit: fit,
        ),
      )
          : const Icon(
        Icons.image_outlined,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

class AppCircleAvatar extends StatelessWidget {
  final String url;
  final double? size;
  final VoidCallback? onSelectImage;
  final Color? borderColor;
  final double? borderWidth;
  final String? defaultAvatar;
  final bool? isEdit;

  const AppCircleAvatar({
    super.key,
    required this.url,
    this.size,
    this.onSelectImage,
    this.borderColor,
    this.borderWidth,
    this.defaultAvatar,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    bool isValidUrl = url.isNotEmpty; //Uri.tryParse(url)?.isAbsolute == true;
    final bytes = Utils().decodeBase64(url);

    return url.isNotEmpty ? Container(
      width: size ?? double.infinity,
      height: size ?? double.infinity,
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular((size ?? 0) / 2),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular((size ?? 0) / 2),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Image(
                image: Utils().providerFromBase64OrAsset(
                  url,
                  fallbackAssetPath: AppAssets.img_df_avatar,
                ),
                width: 58,
                height: 58,
                fit: BoxFit.cover,
              ),
              // child: Image.memory(
              //   bytes,
              //   fit: BoxFit.cover,
              //   gaplessPlayback: true,
              //   filterQuality: FilterQuality.high,
              // )
            ),
            // child: CachedNetworkImage(
            //   imageUrl: url,
            //   progressIndicatorBuilder: (context, url, downloadProgress) {
            //     return SizedBox(
            //       width: size,
            //       height: size,
            //       child: CircularProgressIndicator(
            //         value: downloadProgress.progress,
            //         strokeWidth: 2,
            //       ),
            //     );
            //   },
            //   errorWidget: (context, url, error) {
            //     return SizedBox(
            //       width: double.infinity,
            //       height: double.infinity,
            //       child: Image.asset(
            //         AppAssets.appLogo,
            //         fit: BoxFit.cover,
            //       ),
            //     );
            //   },
            //   fit: BoxFit.fill,
            // ),
          ),
          (isEdit ?? false) ? Positioned(
              bottom: 6,
              right: 0,
              child: Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.transparent),
                ),
                child: Center(
                  child: InkWell(
                    onTap: onSelectImage,
                    child: SvgPicture.asset(AppAssets.icBack,width: 11,height: 11,),
                  ),
                ),
              )) : const SizedBox.shrink()
        ],
      )
    ) :
      Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(size! / 2),
              border: Border.all(width: 1, color: AppColors.gray),
            ),
          ),
          (isEdit ?? false) ? Positioned(
              bottom: 6,
              right: 0,
              child: Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.transparent),
                ),
                child: Center(
                  child: InkWell(
                    onTap: onSelectImage,
                    child: SvgPicture.asset(AppAssets.icBack,width: 11,height: 11,),
                  ),
                ),
              )) : const SizedBox.shrink()
        ],
      );
  }
}
