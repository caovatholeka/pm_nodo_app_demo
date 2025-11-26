import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AvatarSquare extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const AvatarSquare({
    Key? key,
    required this.imageUrl,
    this.size = 70, // 70x70
  }) : super(key: key);

  bool _isValidUrl(String? url) {
    if (url == null) return false;
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;

    final uri = Uri.tryParse(trimmed);
    return uri != null && uri.hasScheme && uri.host.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasValidUrl = _isValidUrl(imageUrl);

    if (!hasValidUrl) {
      return _buildPlaceholder();
    }

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: imageUrl!.trim(),
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return SizedBox(
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.person,
          size: 32,
          color: Colors.grey,
        ),
      ),
    );
  }
}
