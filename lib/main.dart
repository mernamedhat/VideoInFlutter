import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gallery_saver/gallery_saver.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraScreen(),
    );
  }
}

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // Obtain a list of available cameras on the device
    availableCameras().then((cameras) {
      // Select the first camera from the list
      _controller = CameraController(
        cameras[0],
        ResolutionPreset.medium,
      );

      // Initialize the camera
      _initializeControllerFuture = _controller.initialize();
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      // Ensure the camera is initialized
      await _initializeControllerFuture;

      // Start recording video
      await _controller.startVideoRecording();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stopRecording() async {
    try {
      // Stop recording video
      XFile videoFile = await _controller.stopVideoRecording();

      // Save video to the gallery
      GallerySaver.saveVideo(videoFile.path);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Example'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the camera preview
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller.value.isRecordingVideo
              ? _stopRecording()
              : _startRecording();
        },
        child: Icon(
          _controller.value.isRecordingVideo ? Icons.stop : Icons.videocam,
        ),
      ),
    );
  }
}