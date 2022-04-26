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
    _controller = CameraController(cameras.last, ResolutionPreset.ultraHigh);
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
        isAsset:
            true,
        useGpuDelegate:
            false
        );
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
                  Container(
                    height: screenSize.height / 4,
                    margin: EdgeInsets.only(
                        left: screenSize.width / 4,
                        right: screenSize.width / 4,
                        top: screenSize.width / 2),
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(200),
                            bottomRight: Radius.circular(200)),
                        border: Border.all(
                          color: Colors.black,
                          width: 2.0,
                        )),
                  ),
                  Text(output,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20)),
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
