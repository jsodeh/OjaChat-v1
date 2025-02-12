import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/order_confirmation.dart';

class MediaPreview extends StatefulWidget {
  final String url;
  final MediaType type;

  const MediaPreview({
    Key? key,
    required this.url,
    required this.type,
  }) : super(key: key);

  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.type == MediaType.video) {
      _controller = VideoPlayerController.network(widget.url)
        ..initialize().then((_) {
          setState(() {});
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == MediaType.image) {
      return Image.network(
        widget.url,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(Icons.error_outline, size: 48),
          );
        },
      );
    }

    // Video preview
    if (_controller?.value.isInitialized ?? false) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _isPlaying = !_isPlaying;
            _isPlaying ? _controller?.play() : _controller?.pause();
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
            if (!_isPlaying)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
          ],
        ),
      );
    }

    return Center(child: CircularProgressIndicator());
  }
} 