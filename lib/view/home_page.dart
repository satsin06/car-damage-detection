import 'package:camera/camera.dart';
import 'package:car_damage_detection/view/display_results.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

import '../main.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _TongueTestState();
}

class _TongueTestState extends State<HomePage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  CameraImage? cameraImage;
  String output = "";

  @override
  void initState() {
    super.initState();
    loadCamera();
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  loadCamera() {
    _controller = CameraController(cameras.first, ResolutionPreset.ultraHigh);
  }

  runModel() async {
    if (cameraImage != null) {
      var predictions = await Tflite.runModelOnFrame(
          bytesList: cameraImage!.planes.map((plane) {
            return plane.bytes;
          }).toList(),
          imageHeight: cameraImage!.height,
          imageWidth: cameraImage!.width,
          numResults: 2,
          threshold: 0.1,
          asynch: true,
          imageMean: 127.5,
          imageStd: 127.5,
          rotation: 90);
      for (var element in predictions!) {
        output = element['label'];
      }
    }
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels.txt",
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            var screenSize = MediaQuery.of(context).size;
            return AspectRatio(
              aspectRatio: screenSize.width / screenSize.height,
              child: Stack(
                alignment: FractionalOffset.center,
                fit: StackFit.loose,
                children: [
                  CameraPreview(_controller),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;

            final image = await _controller.takePicture();

            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DisplayResult(
                  imagePath: image.path,
                ),
              ),
            );
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
