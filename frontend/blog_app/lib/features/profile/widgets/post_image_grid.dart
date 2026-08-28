import 'package:flutter/material.dart';

class PostImageGrid extends StatelessWidget {
  final List<String> imageUrls;

  const PostImageGrid({super.key, required this.imageUrls});

  Widget _buildImage(String url) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.image_not_supported, color: Colors.grey),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox.shrink();

    if (imageUrls.length == 1) {
      return SizedBox(
        height: 250,
        width: double.infinity,
        child: _buildImage(imageUrls[0]),
      );
    }

    if (imageUrls.length == 2) {
      return SizedBox(
        height: 250,
        child: Row(
          children: [
            Expanded(child: _buildImage(imageUrls[0])),
            const SizedBox(width: 2),
            Expanded(child: _buildImage(imageUrls[1])),
          ],
        ),
      );
    }

    if (imageUrls.length == 3) {
      return SizedBox(
        height: 300,
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                width: double.infinity,
                child: _buildImage(imageUrls[0]),
              ),
            ),
            const SizedBox(height: 2),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Expanded(child: _buildImage(imageUrls[1])),
                  const SizedBox(width: 2),
                  Expanded(child: _buildImage(imageUrls[2])),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 4 or more images: 2x2 grid with overlay on the 4th
    return SizedBox(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildImage(imageUrls[0])),
                const SizedBox(width: 2),
                Expanded(child: _buildImage(imageUrls[1])),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildImage(imageUrls[2])),
                const SizedBox(width: 2),
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildImage(imageUrls[3]),
                      if (imageUrls.length > 4)
                        Container(
                          color: Colors.black.withOpacity(0.5),
                          alignment: Alignment.center,
                          child: Text(
                            '+${imageUrls.length - 4}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
