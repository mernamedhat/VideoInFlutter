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
   CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  bool checker=false;
  @override
  void initState() {
   init();
  super.initState();
    // Obtain a list of available cameras on the device

  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed
    _controller!.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      // Ensure the camera is initialized
      await _initializeControllerFuture;

      // Start recording video
      await _controller!.startVideoRecording();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _stopRecording() async {
    try {
      // Stop recording video
      XFile videoFile = await _controller!.stopVideoRecording();

      // Save video to the gallery
      GallerySaver.saveVideo(videoFile.path);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // _initializeControllerFuture = _controller!.initialize();

  return Scaffold(
      appBar: AppBar(
        title: Text('Camera Example'),
      ),
      body: checker?FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the camera preview
            return CameraPreview(_controller!);
          } else {
            // Otherwise, display a loading indicator
            return Center(child: CircularProgressIndicator());
          }
        },
      ):Container(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller!.value.isRecordingVideo
              ? _stopRecording()
              : _startRecording();
        },
        child:checker? Icon(
          _controller!.value.isRecordingVideo ? Icons.stop : Icons.videocam,
        ):Container(),
      ),
    );
  }

  void init() {
    availableCameras().then((cameras) async {

      // Select the first camera from the list
      _controller = await CameraController(
        cameras[0],
        ResolutionPreset.medium,
      );

      // Initialize the camera
      _initializeControllerFuture = _controller!.initialize();
      checker=true;
      setState(() {

      });
    });
  }
}