import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'subject_selection.dart';

class CameraPage extends StatefulWidget {
  static File? lastCroppedImage;

  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _cameraController;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      _cameraController = CameraController(cameras[0], ResolutionPreset.high);
      await _cameraController?.initialize();
      setState(() {});
    } catch (e) {
      print('Kamera başlatılamadı: $e');
    }
  }

  Future<File?> cropImage(String imagePath) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Kırp',
          toolbarColor: Colors.grey,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          minimumAspectRatio: 1.0,
        ),
      ],
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
    );

    return croppedFile != null ? File(croppedFile.path) : null;
  }

  Future<void> _takePicture() async {
    try {
      final XFile picture = await _cameraController!.takePicture();
      final File? croppedImage = await cropImage(picture.path);
      if (croppedImage != null) {
        CameraPage.lastCroppedImage = croppedImage; // static değişkeni kullan
        await SubjectSelection.selectClass(context);
      }
    } catch (e) {
      print('Fotoğraf çekme hatası: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final File? croppedImage = await cropImage(pickedFile.path);
      if (croppedImage != null) {
        CameraPage.lastCroppedImage = croppedImage;
        await SubjectSelection.selectClass(context);
      }
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: CameraPreview(_cameraController!),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.photo_library,
                      size: 40, color: Colors.white),
                  onPressed: _pickImageFromGallery,
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt,
                      size: 40, color: Colors.white),
                  onPressed: _takePicture,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
