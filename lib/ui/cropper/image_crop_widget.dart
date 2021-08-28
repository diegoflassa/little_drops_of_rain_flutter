import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:image_crop_widget/image_crop_widget.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/helper.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';
import 'package:little_drops_of_rain_flutter/ui/themes/my_color_scheme.dart';

class ImageCropWidgetArguments {
  ImageCropWidgetArguments({this.imageFile, this.imageBytes});

  Uint8List? imageBytes;
  ui.Image? imageFile;
}

class ImageCropWidget extends StatefulWidget {
  const ImageCropWidget({Key? key}) : super(key: key);

  static const String routeName = '/imageCroper';

  @override
  _ImageCropWidgetState createState() => _ImageCropWidgetState();
}

class _ImageCropWidgetState extends State<ImageCropWidget> {
  ui.Image? imageFile;
  bool _imageLoaded = false;
  ui.Image? _imageFile;
  Uint8List? _imageBytes;
  final key = GlobalKey<ImageCropState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadImage() async {
    final codec = await instantiateImageCodec(_imageBytes!);
    final frame = await codec.getNextFrame();
    setState(() {
      imageFile = frame.image;
    });
  }

  Future<void> _loadEmptyImage() async {
    final emptyBytes = Uint8List.fromList(<int>[]);
    final codec = await instantiateImageCodec(emptyBytes);
    final frame = await codec.getNextFrame();
    setState(() {
      imageFile = frame.image;
    });
  }

  void _dismissKeyboard() {
    final currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  Future<ui.Image?> _onCropPress() async {
    _dismissKeyboard();
    ui.Image? croppedImage;
    try {
      if (mounted) {
        croppedImage = await key.currentState!.cropImage();
        // ignore: use_build_context_synchronously
        Helper.showSnackBar(context, 'croppedImage:${croppedImage.toString()}');
        // ignore: use_build_context_synchronously
        final apply = await Helper.showImageThumbnail(context, croppedImage);
        // ignore: use_build_context_synchronously
        Helper.showSnackBar(context, 'apply:$apply');
        if (apply != null && apply) {
          // ignore: use_build_context_synchronously
          await _returnCroppedImage(context, croppedImage);
        }
      }
    } on Error catch (ex) {
      Helper.showSnackBar(context, 'ex:$ex');
    } on Exception catch (ex) {
      Helper.showSnackBar(context, 'ex:$ex');
    }
    return croppedImage;
  }

  @override
  Widget build(BuildContext context) {
    _getArguments();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).cropFace),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            _dismissKeyboard();
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          IconButton(icon: const Icon(Icons.crop), onPressed: _onCropPress),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            if (imageFile != null)
              Expanded(
                child: ImageCrop(key: key, image: imageFile!),
              ),
            Container(
              width: double.infinity,
              color: MyColorScheme().primary,
              child: IconButton(
                color: Colors.white,
                onPressed: _onCropPress,
                tooltip: AppLocalizations.of(context).crop,
                icon: const Icon(Icons.crop),
              ),
            ),
            const SizedBox(height: Constants.DEFAULT_AD_BOTTOM_SPACE),
          ],
        ),
      ),
    );
  }

  void _getArguments() {
    final args =
        ModalRoute.of(context)?.settings.arguments as ImageCropWidgetArguments?;
    if (args != null && !_imageLoaded) {
      _imageLoaded = true;
      _imageFile = args.imageFile;
      _imageBytes = args.imageBytes;
      if (_imageFile == null) {
        if (_imageBytes != null) {
          _loadImage();
        } else {
          _loadEmptyImage();
        }
      }
    }
  }

  Future<dynamic> _returnCroppedImage(
      BuildContext context, ui.Image img) async {
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();
    if (mounted) {
      Navigator.of(context).pop(buffer);
    }
  }
}
