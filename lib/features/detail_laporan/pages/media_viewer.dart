import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class MediaViewerPage extends StatefulWidget {
  final String path;
  final bool isVideo;

  const MediaViewerPage({Key? key, required this.path, required this.isVideo}) : super(key: key);

  @override
  State<MediaViewerPage> createState() => _MediaViewerPageState();
}

class _MediaViewerPageState extends State<MediaViewerPage> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _init = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) _initVideo();
  }

  Future<void> _initVideo() async {
    final path = widget.path;
    if (path.startsWith('http')) {
      _videoController = VideoPlayerController.network(path);
    } else {
      _videoController = VideoPlayerController.file(File(path));
    }
    await _videoController!.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
      looping: false,
      showOptions: true,
    );
    setState(() => _init = true);
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: widget.isVideo
            ? (_init
                ? Chewie(controller: _chewieController!)
                : const CircularProgressIndicator())
            : InteractiveViewer(
                child: widget.path.startsWith('http')
                    ? Image.network(widget.path, fit: BoxFit.contain)
                    : Image.file(File(widget.path), fit: BoxFit.contain),
              ),
      ),
    );
  }
}