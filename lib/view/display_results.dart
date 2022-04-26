import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

class DisplayResult extends StatefulWidget {
  final String imagePath;

  const DisplayResult({Key? key, required this.imagePath})
      : super(key: key);

  @override
  State<DisplayResult> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayResult> {
  String output = "";
  List<String> urls = [];

  @override
  void initState() {
    loadModel();
    runModel();
    //firebaseStorage();
    super.initState();
  }

  runModel() async {
    var recognitions = await Tflite.runModelOnImage(
        path: widget.imagePath, // required
        imageMean: 0.0, // defaults to 117.0
        imageStd: 255.0, // defaults to 1.0
        numResults: 2, // defaults to 5
        threshold: 0.2, // defaults to 0.1
        asynch: true // defaults to true
        );
    for (var element in recognitions!) {
      setState(() {
        output = element['label'];
      });
    }
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/model.tflite",
        labels: "assets/labels.txt",
        numThreads: 1, // defaults to 1
        isAsset:
            true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate:
            false // defaults to false, set to true to use GPU delegate
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: Column(
        children: [
          Image.file(File(widget.imagePath)),
          Text(output,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
    );
  }
}
