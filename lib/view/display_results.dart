import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';

class DisplayResult extends StatefulWidget {
  final String imagePath;

  const DisplayResult({Key? key, required this.imagePath}) : super(key: key);

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
        path: widget.imagePath,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 2,
        threshold: 0.2,
        asynch: true);
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
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Display the Picture'),
        centerTitle: true,
      ),
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
