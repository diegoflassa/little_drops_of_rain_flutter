import 'dart:io';
import 'dart:typed_data';

// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:image_cropper/image_cropper.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:image_picker/image_picker.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:intl/intl.dart';
import 'package:little_drops_of_rain_flutter/data/dao/users_dao.dart';
import 'package:little_drops_of_rain_flutter/data/entities/user.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/helper.dart';
import 'package:little_drops_of_rain_flutter/helpers/logged_user.dart';
import 'package:little_drops_of_rain_flutter/i18n/app_localizations.dart';
import 'package:little_drops_of_rain_flutter/routing/routes.dart';
import 'package:little_drops_of_rain_flutter/ui/cropper/image_crop_widget.dart';
import 'package:little_drops_of_rain_flutter/ui/my_scaffold.dart';
import 'package:little_drops_of_rain_flutter/ui/themes/my_text_style.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({Key? key, this.title = Constants.APP_NAME})
      : super(key: key);

  static const String routeName = '/myProfile';
  final String? title;

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  User _user = (LoggedUser().hasUser()) ? LoggedUser().user! : User();
  final _formKey = GlobalKey<FormState>();
  XFile? _pickedFile;
  DateTime _selectedDate = DateTime.now();
  final _dateFormatter = DateFormat('dd-MM-yyyy');
  Uint8List? _imageBytes;
  var _gettingImage = false;
  var _gotImage = false;
  Widget _avatar = const SizedBox(
    width: 100,
    height: 100,
  );

  @override
  Widget build(BuildContext context) {
    final scaffold = MyScaffold(
      title: (widget.title != null) ? widget.title : '',
      body: Builder(
        builder: _buildBody,
      ),
    );
    return scaffold;
  }

  @override
  void initState() {
    super.initState();
    if (_user.birthdate != null) {
      _selectedDate = _user.birthdate!.toDate();
    }
    _user.getImageData().then((value) {
      _imageBytes = value;
      _getUserImage();
    });
  }

  Widget _buildBody(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints.loose(
            Size(640, MediaQuery
                .of(context)
                .size
                .height)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              vertical: Constants.DEFAULT_EDGE_INSETS_VERTICAL,
              horizontal: Constants.DEFAULT_EDGE_INSETS_HORIZONTAL),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                _avatar,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () async {
                        _pickedFile = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        //_pickedFile = PickedFile(
                        //    '/storage/emulated/0/Download/tardis-wallpaper.jpeg');
                        //_pickedFile = PickedFile(
                        //    '/assets/images/no_product.jpeg');
                        if (_pickedFile != null) {
                          final bytes = await _pickedFile!.readAsBytes();
                          if (bytes.lengthInBytes >
                              Constants.DEFAULT_MAX_UPLOAD_FILE_SIZE) {
                            if (mounted) {
                              Helper.showSnackBar(context,
                                  AppLocalizations
                                      .of(context)
                                      .imageSizeTooBig);
                            }
                          } else {
                            await _cropImage();
                            await _getUserImage();
                          }
                        }
                      },
                      child: Text(AppLocalizations
                          .of(context)
                          .changeImage),
                    ),
                    if (!kIsWeb && _pickedFile != null)
                      const SizedBox(
                        width: 10,
                      ),
                    if (!kIsWeb && _pickedFile != null)
                      ElevatedButton(
                        onPressed: () async {
                          await _cropImage();
                          await _getUserImage();
                        },
                        child: Text(AppLocalizations
                            .of(context)
                            .cropImage),
                      ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: Text(
                    _user.email,
                    style: const MyTextStyle.black(),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  initialValue: _user.name,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    hintText: AppLocalizations
                        .of(context)
                        .userName,
                    labelText: AppLocalizations
                        .of(context)
                        .userName,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations
                          .of(context)
                          .userName;
                    } else {
                      _user.name = value;
                      return null;
                    }
                  },
                ),
                TextFormField(
                  initialValue: _user.surename,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    hintText: AppLocalizations
                        .of(context)
                        .userSurename,
                    labelText: AppLocalizations
                        .of(context)
                        .userSurename,
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      _user.surename = value;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: _user.nickname,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    hintText: AppLocalizations
                        .of(context)
                        .userNickname,
                    labelText: AppLocalizations
                        .of(context)
                        .userNickname,
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      _user.nickname = value;
                    }
                    return null;
                  },
                ),
                Row(children: <Widget>[
                  const Spacer(),
                  Text(_dateFormatter.format(_selectedDate)),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final dateTime = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100));
                      setState(() {
                        _selectedDate = dateTime!;
                      });
                      _user.birthdate = Timestamp.fromDate(dateTime!);
                    },
                    child: Text(AppLocalizations
                        .of(context)
                        .userBirthdate),
                  ),
                ]),
                CheckboxListTile(
                  value: _user.receiveNotifications,
                  onChanged: (isChecked) {
                    setState(() {
                      _user.receiveNotifications = isChecked!;
                    });
                  },
                  subtitle:
                  Text(AppLocalizations
                      .of(context)
                      .receiveNotifications),
                  title: Text(
                    AppLocalizations
                        .of(context)
                        .receiveNotifications,
                    style: const TextStyle(fontSize: 14),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.green,
                ),
                Row(
                  children: <Widget>[
                    const Spacer(),
                    ElevatedButton(
                      onPressed: (_user.uid != null && _user.uid!.isNotEmpty)
                          ? () {
                        // Validate returns true if the form is valid, otherwise false.
                        if (_formKey.currentState!.validate()) {
                          if (_user.imageUrl != null &&
                              _user.imageBytes != _imageBytes) {
                            _user.previousImageUrl = _user.imageUrl;
                            _user.imageUrl = null;
                          }
                          _user.imageBytes = _imageBytes;
                          UsersDao().update(_user);
                          _user = (LoggedUser().hasUser())
                              ? LoggedUser().user!
                              : User();
                          Helper.showSnackBar(context,
                              AppLocalizations
                                  .of(context)
                                  .saving);
                        }
                      }
                          : null,
                      child: Text(AppLocalizations
                          .of(context)
                          .save),
                    ),
                  ],
                ),
                const SizedBox(
                    height: Constants.DEFAULT_AD_BOTTOM_SPACE, width: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _cropImage() async {
    _gotImage = false;
    if (_pickedFile != null) {
      if (!kIsWeb) {
        final cropped = await ImageCropper.cropImage(
          sourcePath: _pickedFile!.path,
          //aspectRatioPresets: [CropAspectRatioPreset.square]
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: AppLocalizations
                  .of(context)
                  .cropImage,
              lockAspectRatio: false),
          iosUiSettings: IOSUiSettings(
            title: AppLocalizations
                .of(context)
                .cropImage,
          ),
        );
        if (cropped != null) {
          _imageBytes = File(cropped.uri.toString()).readAsBytesSync();
        }
      } else {
        final icwa = ImageCropWidgetArguments(
            imageBytes: await _pickedFile!.readAsBytes());
        Uint8List? bytes;
        if (mounted) {
          bytes = await Navigator.pushNamed(context, Routes.imageCropWidget,
              arguments: icwa) as Uint8List?;
        }
        _imageBytes = bytes;
      }
    }
    return Future.value(null);
  }

  Future<void> _getUserImage() async {
    if (!_gettingImage && !_gotImage) {
      _gettingImage = true;
      setState(() {
        _avatar = const SizedBox(
          width: Constants.DEFAULT_MY_PROFILE_IMAGE_WIDTH,
          height: Constants.DEFAULT_MY_PROFILE_IMAGE_HEIGHT,
          child: FittedBox(
              fit: BoxFit.scaleDown, child: CircularProgressIndicator()),
        );
      });
      if (_imageBytes != null && _imageBytes!.isNotEmpty) {
        setState(() {
          _gotImage = true;
          _avatar = Image.memory(
            _imageBytes!,
            fit: BoxFit.scaleDown,
            width: Constants.DEFAULT_MY_PROFILE_IMAGE_WIDTH,
            height: Constants.DEFAULT_MY_PROFILE_IMAGE_HEIGHT,
          );
        });
      }
      if (!_gotImage) {
        setState(() {
          _avatar = const SizedBox(
            width: Constants.DEFAULT_MY_PROFILE_IMAGE_WIDTH,
            height: Constants.DEFAULT_MY_PROFILE_IMAGE_HEIGHT,
          );
        });
      }
      _gettingImage = false;
    }
  }
}
