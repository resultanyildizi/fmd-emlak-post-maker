import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:ElazizSepetiPostMaker/application/my_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PostCreator with ChangeNotifier {
  ByteData _imageByteData;
  File _croppedImage;
  bool isSaved = false;
  bool isGeneratingImage = false;
  MyBanner banner;

  ByteData get imageByteData => _imageByteData;

  Future<void> selectImage(ImageSource source) async {
    var imagePicker = ImagePicker();
    final pickedFile = await imagePicker.getImage(source: source);
    imagePicker = null;

    if (pickedFile != null) {
      _croppedImage = await ImageCropper.cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        androidUiSettings: const AndroidUiSettings(
          toolbarTitle: 'Resmi Kırp',
          toolbarColor: Colors.redAccent,
          toolbarWidgetColor: Colors.white,
          cropFrameColor: Colors.transparent,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
          showCropGrid: false,
          hideBottomControls: true,
        ),
      );
      await generateImage();
    }
  }

  Future<void> generateImage() async {
    if (_croppedImage != null) {
      ui.Image _croppedImageToDraw;
      ui.Image _overlayImageToDraw;
      ui.Image _bannerImageToDraw;

      Uint8List bytesCropped;
      Uint8List bytesOverlay;
      Uint8List bytesBanner;

      _imageByteData = null;
      isGeneratingImage = true;
      isSaved = false;
      notifyListeners();

      final overlayImage = await rootBundle.load('images/instapost_frame.png');
      final bannerImage = banner?.bannerImagePath != null
          ? await rootBundle.load(banner.bannerImagePath)
          : null;

      final recorder = ui.PictureRecorder();
      final canvas =
          Canvas(recorder, const Rect.fromLTWH(0, 0, 1000.0, 1000.0));
      final paint = ui.Paint();

      bytesCropped = _croppedImage.readAsBytesSync();
      bytesOverlay = overlayImage.buffer.asUint8List();
      bytesBanner = bannerImage?.buffer?.asUint8List();

      final completerCropped = Completer<ui.Image>();
      ui.decodeImageFromList(bytesCropped, (result) {
        completerCropped.complete(result);
      });

      _croppedImageToDraw = await completerCropped.future;
      final _croppedImageSize = Size(_croppedImageToDraw.width.toDouble(),
          _croppedImageToDraw.height.toDouble());

      final FittedSizes fittedSizes = applyBoxFit(
          BoxFit.cover, _croppedImageSize, const Size(1000.0, 1000.0));

      final Rect _croppedImageRect = Alignment.center
          .inscribe(fittedSizes.source, Offset.zero & _croppedImageSize);

      final completerOverlay = Completer<ui.Image>();
      ui.decodeImageFromList(bytesOverlay, (result) {
        completerOverlay.complete(result);
      });

      Completer<ui.Image> completerBanner;
      if (bytesBanner != null) {
        completerBanner = Completer<ui.Image>();
        ui.decodeImageFromList(bytesBanner, (result) {
          completerBanner.complete(result);
        });
      } else {
        completerBanner = null;
      }

      _overlayImageToDraw = await completerOverlay.future;

      if (completerBanner != null) {
        _bannerImageToDraw = await completerBanner.future;
      }

      canvas.drawImageRect(_croppedImageToDraw, _croppedImageRect,
          const Rect.fromLTWH(0, 0, 1000.0, 1000.0), paint);

      canvas.drawImage(_overlayImageToDraw, const ui.Offset(0.0, 0.0), paint);

      if (_bannerImageToDraw != null) {
        canvas.drawImage(_bannerImageToDraw, const ui.Offset(0.0, 0.0), paint);
      }

      final picture = recorder.endRecording();
      _imageByteData = await (await picture.toImage(1000, 1000))
          .toByteData(format: ui.ImageByteFormat.png);
      isGeneratingImage = false;
      notifyListeners();
    }
  }

  Future saveImage() async {
    if (_imageByteData != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/FmdEmlakInsta/');

      String path;

      if (!(await imagesDir.exists())) {
        await imagesDir.create(recursive: true);
      }
      path = imagesDir.path;

      final newImageFile = File(join(path, '${DateTime.now().toString()}.png'));
      final Uint8List byteList = _imageByteData.buffer.asUint8List();
      newImageFile.writeAsBytesSync(byteList);

      if (await Permission.storage.request().isGranted) {
        assert(newImageFile != null);

        await GallerySaver.saveImage(newImageFile?.path,
            albumName: 'Fmd Emlak Post');
        _imageByteData = null;
        isSaved = true;
        notifyListeners();
      }
    }
  }

  Future<void> changeSelectedBanner(MyBanner banner) async {
    this.banner = banner;
    await generateImage();
    notifyListeners();
  }
}
