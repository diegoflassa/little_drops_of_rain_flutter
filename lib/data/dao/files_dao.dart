import 'dart:io' as io;
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:little_drops_of_rain_flutter/data/dao/products_dao.dart';
import 'package:little_drops_of_rain_flutter/enums/file_type.dart' as my_app;
import 'package:little_drops_of_rain_flutter/extensions/string_extensions.dart';
import 'package:little_drops_of_rain_flutter/helpers/constants.dart';
import 'package:little_drops_of_rain_flutter/helpers/my_logger.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:pedantic/pedantic.dart';

class FilesDao {
  factory FilesDao() {
    return _instance;
  }

  FilesDao._internal();

  static const String COLLECTION_USERS_AVATARS = 'avatars';
  static const String COLLECTION_PATH_FACES = 'faces';
  static const String COLLECTION_PATH = 'little_drops_of_rain_flutter_images';
  Reference products = FirebaseStorage.instance
      .ref()
      .child(COLLECTION_PATH)
      .child(ProductsDao.COLLECTION_PATH);
  Reference productsFaces = FirebaseStorage.instance
      .ref()
      .child(COLLECTION_PATH)
      .child(ProductsDao.COLLECTION_PATH)
      .child(COLLECTION_PATH_FACES);
  Reference usersAvatars = FirebaseStorage.instance
      .ref()
      .child(COLLECTION_PATH)
      .child(COLLECTION_USERS_AVATARS);

  //CollectionReference stories =
  //  FirebaseFirestore.instance.collection(StoriesDao.COLLECTION_PATH);

  //CollectionReference universes =
  //  FirebaseFirestore.instance.collection(UniversesDao.COLLECTION_PATH);

  static final FilesDao _instance = FilesDao._internal();

  Future<UploadTask?> uploadFileAsUri(Uri file, my_app.FileType type,
      {String? uploadName}) async {
    return uploadFile(file.toString(), type, uploadName: uploadName);
  }

  /// The user selects a file, and the task is added to the list.
  Future<UploadTask?> uploadFile(String file, my_app.FileType type,
      {String? uploadName}) async {
    if (file.isNotEmpty && type != my_app.FileType.UNKNOWN) {
      UploadTask? uploadTask;

      try {
        final bytes = await file.downloadBytes();
        if (bytes != null && bytes.isNotEmpty) {
          String fileName;
          if (uploadName != null) {
            fileName = uploadName;
          } else {
            fileName = basename(file.contains('?') ? file.split('?')[0] : file);
          }
          var mimeType = lookupMimeType(file, headerBytes: bytes);
          mimeType = (mimeType == null ||
                  mimeType.isEmpty ||
                  !mimeType.startsWith('image'))
              ? 'image/*'
              : mimeType;
          final customMetadata = {
            Constants.FILE_METADATA_KEY_FILE_PATH: file,
            Constants.FILE_METADATA_KEY_ORIGINAL_NAME:
                basename(file.contains('?') ? file.split('?')[0] : file)
          };
          final metadata = SettableMetadata(
              contentType: mimeType, customMetadata: customMetadata);
          //metadata = null;

          if (kIsWeb) {
            final pickedFile = PickedFile(file.toString());
            switch (type) {
              case my_app.FileType.HERO:
                {
                  uploadTask = products
                      .child(fileName)
                      .putData(await pickedFile.readAsBytes(), metadata);
                }
                break;
              case my_app.FileType.HERO_FACE:
                {
                  uploadTask = productsFaces
                      .child(fileName)
                      .putData(await pickedFile.readAsBytes(), metadata);
                }
                break;
              case my_app.FileType.USER_AVATAR:
                {
                  uploadTask = usersAvatars
                      .child(fileName)
                      .putData(await pickedFile.readAsBytes(), metadata);
                }
                break;
              case my_app.FileType.UNKNOWN:
                // Do nothing
                break;
            }
          } else {
            switch (type) {
              case my_app.FileType.HERO:
                {
                  uploadTask =
                      products.child(fileName).putFile(io.File(file), metadata);
                }
                break;
              case my_app.FileType.HERO_FACE:
                {
                  uploadTask = productsFaces
                      .child(fileName)
                      .putFile(io.File(file), metadata);
                }
                break;
              case my_app.FileType.USER_AVATAR:
                {
                  uploadTask = usersAvatars
                      .child(fileName)
                      .putFile(io.File(file), metadata);
                }
                break;
              case my_app.FileType.UNKNOWN:
                // Do nothing
                break;
            }
          }

          if (uploadTask != null) {
            await uploadTask.then((value) {
              decodeImageFromList(bytes, (image) async {
                final customMetadata = {
                  Constants.FILE_METADATA_KEY_WIDTH: image.width.toString(),
                  Constants.FILE_METADATA_KEY_HEIGHT: image.height.toString(),
                };
                final sizeMetadata = SettableMetadata(
                    contentType: mimeType, customMetadata: customMetadata);

                await updateFileMetadata(uploadName!, type, sizeMetadata);
              });
            });
          }
        } else {
          MyLogger().logger.e('File bytes is null for ${file.toString()}');
        }
      } on Exception catch (ex) {
        if (!kIsWeb) {
          unawaited(FirebaseCrashlytics.instance.log(ex.toString()));
        }
        MyLogger().logger.e(ex);
      } on Error catch (ex) {
        if (!kIsWeb) {
          unawaited(
              FirebaseCrashlytics.instance.recordError(ex, ex.stackTrace));
        }
        MyLogger().logger.e(ex);
      }

      return Future.value(uploadTask);
    } else {
      return null;
    }
  }

  Future<UploadTask?> updateFileAsUri(
      Uri file, my_app.FileType type, String uploadName) async {
    return updateFile(file.toString(), type, uploadName);
  }

  /// The user selects a file, and the task is added to the list.
  Future<UploadTask?> updateFile(
      String file, my_app.FileType type, String uploadName) async {
    if (file.isNotEmpty && type != my_app.FileType.UNKNOWN) {
      UploadTask? uploadTask;

      final bytes = await file.downloadBytes();
      var mimeType = lookupMimeType('', headerBytes: bytes);
      mimeType = (mimeType == null ||
              mimeType.isEmpty ||
              !mimeType.startsWith('image'))
          ? 'image/*'
          : mimeType;
      final customMetaData = {
        Constants.FILE_METADATA_KEY_FILE_PATH: file,
        Constants.FILE_METADATA_KEY_ORIGINAL_NAME:
            basename(file.contains('?') ? file.split('?')[0] : file)
      };
      if (bytes != null && bytes.isNotEmpty) {
        final metadata = SettableMetadata(
            contentType: mimeType, customMetadata: customMetaData);
        //metadata = null;

        if (kIsWeb) {
          switch (type) {
            case my_app.FileType.HERO:
              {
                uploadTask = products.child(uploadName).putData(bytes, metadata);
              }
              break;
            case my_app.FileType.HERO_FACE:
              {
                uploadTask =
                    productsFaces.child(uploadName).putData(bytes, metadata);
              }
              break;
            case my_app.FileType.USER_AVATAR:
              {
                uploadTask =
                    usersAvatars.child(uploadName).putData(bytes, metadata);
              }
              break;
            case my_app.FileType.UNKNOWN:
              // Do nothing
              break;
          }
        } else {
          switch (type) {
            case my_app.FileType.HERO:
              {
                uploadTask = products.child(uploadName).putData(bytes, metadata);
              }
              break;
            case my_app.FileType.HERO_FACE:
              {
                uploadTask =
                    productsFaces.child(uploadName).putData(bytes, metadata);
              }
              break;
            case my_app.FileType.USER_AVATAR:
              {
                uploadTask =
                    usersAvatars.child(uploadName).putData(bytes, metadata);
              }
              break;
            case my_app.FileType.UNKNOWN:
              // Do nothing
              break;
          }
        }

        if (uploadTask != null) {
          await uploadTask.then((value) {
            if (uploadName.isNotEmpty) {
              decodeImageFromList(bytes, (image) async {
                final customMetadata = {
                  Constants.FILE_METADATA_KEY_WIDTH: image.width.toString(),
                  Constants.FILE_METADATA_KEY_HEIGHT: image.height.toString(),
                };
                final sizeMetadata = SettableMetadata(
                    contentType: mimeType, customMetadata: customMetadata);
                await updateFileMetadata(uploadName, type, sizeMetadata);
              });
            }
          });
        }
      } else {
        MyLogger().logger.e('File bytes is null for $file');
      }
      return Future.value(uploadTask);
    } else {
      return null;
    }
  }

  /// The user selects a file, and the task is added to the list.
  Future<UploadTask?> updateFileAsBytes(
      Uint8List bytes, my_app.FileType type, String uploadName) async {
    if (bytes.isNotEmpty && type != my_app.FileType.UNKNOWN) {
      UploadTask? uploadTask;

      final rng = Random();
      final randomImageName = 'image_file_${rng.nextInt(10000).toString()}';
      var mimeType = lookupMimeType('', headerBytes: bytes);
      mimeType = (mimeType == null ||
              mimeType.isEmpty ||
              !mimeType.startsWith('image'))
          ? 'image/*'
          : mimeType;
      final customMetadata = {
        Constants.FILE_METADATA_KEY_FILE_PATH: randomImageName,
        Constants.FILE_METADATA_KEY_ORIGINAL_NAME: uploadName,
      };
      final metadata = SettableMetadata(
          contentType: mimeType, customMetadata: customMetadata);
      //metadata = null;

      if (kIsWeb) {
        switch (type) {
          case my_app.FileType.HERO:
            {
              uploadTask = products.child(uploadName).putData(bytes, metadata);
            }
            break;
          case my_app.FileType.HERO_FACE:
            {
              uploadTask =
                  productsFaces.child(uploadName).putData(bytes, metadata);
            }
            break;
          case my_app.FileType.USER_AVATAR:
            {
              uploadTask =
                  usersAvatars.child(uploadName).putData(bytes, metadata);
            }
            break;
          case my_app.FileType.UNKNOWN:
            // Do nothing
            break;
        }
      } else {
        switch (type) {
          case my_app.FileType.HERO:
            {
              uploadTask = products.child(uploadName).putData(bytes, metadata);
            }
            break;
          case my_app.FileType.HERO_FACE:
            {
              uploadTask =
                  productsFaces.child(uploadName).putData(bytes, metadata);
            }
            break;
          case my_app.FileType.USER_AVATAR:
            {
              uploadTask =
                  usersAvatars.child(uploadName).putData(bytes, metadata);
            }
            break;
          case my_app.FileType.UNKNOWN:
            // Do nothing
            break;
        }
      }

      if (uploadTask != null) {
        await uploadTask.then((value) {
          if (uploadName.isNotEmpty) {
            decodeImageFromList(bytes, (image) async {
              final customMetadata = {
                Constants.FILE_METADATA_KEY_WIDTH: image.width.toString(),
                Constants.FILE_METADATA_KEY_HEIGHT: image.height.toString(),
              };
              final sizeMetadata = SettableMetadata(
                  contentType: mimeType, customMetadata: customMetadata);
              await updateFileMetadata(uploadName, type, sizeMetadata);
            });
          }
        });
      }

      return Future.value(uploadTask);
    } else {
      return null;
    }
  }

  Future<void> updateFileMetadata(
      String name, my_app.FileType type, SettableMetadata metadata) async {
    switch (type) {
      case my_app.FileType.HERO:
        {
          await products.child(name).updateMetadata(metadata);
        }
        break;
      case my_app.FileType.HERO_FACE:
        {
          await productsFaces.child(name).updateMetadata(metadata);
        }
        break;
      case my_app.FileType.USER_AVATAR:
        {
          await usersAvatars.child(name).updateMetadata(metadata);
        }
        break;
      case my_app.FileType.UNKNOWN:
        // Do nothing
        break;
    }
  }

  Future<bool> deleteAsUri(Uri remoteFile) async {
    if(remoteFile.path.isNotEmpty && remoteFile.path.toLowerCase() != 'null') {
      return delete(remoteFile.toString());
    }else{
      return Future.value(false);
    }
  }

  Future<bool> delete(String remoteFile) async {
    var ret = Future.value(false);
    if (remoteFile.isNotEmpty) {
      final ref = FirebaseStorage.instance.refFromURL(remoteFile);
      await ref.getDownloadURL().then((_) {
        ref.delete();
        ret = Future.value(true);
      }).onError((error, stackTrace) {
        MyLogger().logger.e(
            '[FilesDao.delete]Error deleting url: $remoteFile. Got error: ${error.toString()}');
      });
    }
    return ret;
  }

  Future<Uint8List?> downloadBytesAsUri(Uri remoteFile) async {
    return downloadBytes(remoteFile.toString());
  }

  Future<Uint8List?> downloadBytes(String remoteFile) async {
    if (remoteFile.isNotEmpty && remoteFile.isFromStorage()) {
      Uint8List? ret;
      try {
        final ref = FirebaseStorage.instance.refFromURL(remoteFile);
        await ref.getDownloadURL().then((_) async {
          ret = await ref.getData();
        }).catchError((dynamic e) {
          final ex = e as Exception;
          MyLogger().logger.e(
              '[FilesDao.downloadBytes]Error downloading data for url: $remoteFile. Got error: ${ex.toString()}');
        });
      } catch (ex) {
        MyLogger().logger.e(
            '[FilesDao.downloadBytes]Error downloading data for url: $remoteFile. Got error: ${ex.toString()}');
      }
      return Future.value(ret);
    } else {
      return null;
    }
  }

  Future<FullMetadata?> getMetadataAsUri(Uri remoteFile) async {
    return getMetadata(remoteFile.toString());
  }

  Future<FullMetadata?> getMetadata(String remoteFile) async {
    if (remoteFile.isNotEmpty && remoteFile.isFromStorage()) {
      FullMetadata? ret;
      try {
        final ref = FirebaseStorage.instance.refFromURL(remoteFile);
        await ref.getDownloadURL().then((_) async {
          ret = await ref.getMetadata();
        }).catchError((dynamic e) {
          final ex = e as Exception;
          MyLogger().logger.e(
              'Error retrieving metadata for uri: $remoteFile. Got error: ${ex.toString()}');
        });
      } catch (ex) {
        MyLogger().logger.e(
            'Error retrieving metadata for uri: $remoteFile. Got error: ${ex.toString()}');
      }
      return Future.value(ret);
    } else {
      return null;
    }
  }
}
