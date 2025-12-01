import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/commons/app_assets.dart';
import '../../core/commons/app_colors.dart';

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
    this.size = 40,
    this.onSelectImage,
    this.borderColor,
    this.borderWidth,
    this.defaultAvatar,
    this.isEdit = false,
  });

  bool get _isNetwork =>
      url.startsWith('http://') || url.startsWith('https://');

  bool get _isSvg => url.toLowerCase().endsWith('.svg');

  String get _fallback =>
      defaultAvatar ?? AppAssets.img_df_avatar;

  @override
  Widget build(BuildContext context) {
    final avatarSize = size ?? 40;

    return SizedBox(
      width: avatarSize,
      height: avatarSize,
      child: Stack(
        children: [
          ClipOval(
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(
                  color: borderColor ?? Colors.transparent,
                  width: borderWidth ?? 1,
                ),
              ),
              child: _buildImage(),
            ),
          ),

          if (isEdit == true)
            Positioned(
              bottom: 4,
              right: 0,
              child: InkWell(
                onTap: onSelectImage,
                child: Container(
                  height: 24,
                  width: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppAssets.icBack,
                      width: 12,
                      height: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    if (url.isEmpty) {
      return _buildAsset(_fallback);
    }

    if (_isNetwork) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (_, __, ___) => _buildAsset(_fallback),
      );
    }

    return _buildAsset(url);
  }

  Widget _buildAsset(String path) {
    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        fit: BoxFit.cover,
      );
    }

    return Image.asset(
      path,
      fit: BoxFit.cover,
    );
  }
}

