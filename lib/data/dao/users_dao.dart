// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_storage/firebase_storage.dart';
import 'package:little_drops_of_rain_flutter/data/dao/files_dao.dart';
import 'package:little_drops_of_rain_flutter/data/entities/user.dart' as my_app;
import 'package:little_drops_of_rain_flutter/enums/file_type.dart';
import 'package:little_drops_of_rain_flutter/extensions/uri_extensions.dart';
import 'package:little_drops_of_rain_flutter/helpers/helper.dart';
import 'package:little_drops_of_rain_flutter/helpers/images_cache.dart';
import 'package:little_drops_of_rain_flutter/helpers/my_logger.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:mime/mime.dart';
import 'package:pedantic/pedantic.dart';

class UsersDao {
  factory UsersDao() {
    return _instance;
  }

  UsersDao._internal();

  static const String COLLECTION_PATH = 'users';
  CollectionReference<Map<String, dynamic>> users =
      FirebaseFirestore.instance.collection(COLLECTION_PATH);

  static final UsersDao _instance = UsersDao._internal();

  Future<my_app.User?> getByUId(String uid) async {
    my_app.User? ret;
    final docs =
        (await users.where(my_app.User.UID, isEqualTo: uid).get()).docs;
    if (docs.length == 1) {
      ret = Helper.queryDocumentSnapshotToUser(docs[0]);
    }
    return ret;
  }

  Future<my_app.User?> getByEmail(String email) async {
    my_app.User? ret;
    final docs =
        (await users.where(my_app.User.EMAIL, isEqualTo: email).get()).docs;
    if (docs.isNotEmpty) {
      ret = Helper.queryDocumentSnapshotToUser(docs[0]);
    }
    return ret;
  }

  Future<QuerySnapshot> getAll() {
    return users.get();
  }

  Future<void> update(my_app.User user) async {
    if (user.uid != null) {
      await updateUserImage(user).then((value) async {
        if (value != null) {
          await value.then((snapshot) async {
            if (snapshot.state == TaskState.success) {
              user.imageUrl = Uri.parse(await snapshot.ref.getDownloadURL());
              unawaited(ImagesCache.writeAsUri(
                  user.imageUrl!, (await snapshot.ref.getData())!));
              if (user.previousImageUrl != null &&
                  user.imageUrl!.lastPath() !=
                      user.previousImageUrl!.lastPath()) {
                await FilesDao().deleteAsUri(user.previousImageUrl!);
              }
            } else {
              user.imageUrl = user.previousImageUrl;
            }
            await users
                .doc(user.uid)
                .update(user.toMap())
                .then((value) => MyLogger().logger.i('User Updated'))
                .catchError((dynamic error) =>
                    MyLogger().logger.e('Failed to update user: $error'));
          });
        } else {
          await users
              .doc(user.uid)
              .update(user.toMap())
              .then((value) => MyLogger().logger.i('User Updated'))
              .catchError((dynamic error) =>
                  MyLogger().logger.e('Failed to update user: $error'));
        }
      });
    }
    return Future.value(null);
  }

  Future<void> delete(my_app.User user) {
    if (user.uid != null) {
      return users
          .doc(user.uid)
          .delete()
          .then((value) => MyLogger().logger.i('User Deleted'))
          .catchError((dynamic error) =>
              MyLogger().logger.e('Failed to delete user: $error'));
    } else {
      return Future.value(null);
    }
  }

  Future<void> deleteAll() {
    final batch = FirebaseFirestore.instance.batch();

    return users.get().then((querySnapshot) {
      for (final document in querySnapshot.docs) {
        batch.delete(document.reference);
      }

      return batch.commit();
    });
  }

  Future<void> add(my_app.User user) async {
    if (user.uid == null) {
      await updateUserImage(user).then((value) async {
        if (value != null) {
          await value.then((snapshot) async {
            if (snapshot.state == TaskState.success) {
              user.imageUrl = Uri.parse(await snapshot.ref.getDownloadURL());
              unawaited(ImagesCache.writeAsUri(
                  user.imageUrl!, (await snapshot.ref.getData())!));
            } else {
              user.imageUrl = Uri();
            }
            await _addAndUpdateUserId(user);
          });
        } else {
          await _addAndUpdateUserId(user);
        }
      });
    } else {
      unawaited(update(user));
    }
    return Future.value(null);
  }

  Future<void> _addAndUpdateUserId(my_app.User user) async {
    final dr = await users.add(user.toMap());
    user.uid = dr.id;
    unawaited(update(user));
  }

  Future<String> _getUserAvatarUploadName(my_app.User user) async {
    var filePath = '';
    String? mimeType;
    if (user.imageUrl != null) {
      filePath = user.imageUrl!.path.split('/').last;
      filePath = (filePath.isNotEmpty) ? filePath : user.imageUrl!.path;
      final bytes = await user.imageUrl!.downloadBytes();
      mimeType = lookupMimeType(filePath, headerBytes: bytes);
    }
    var extension = '';
    if (mimeType != null && mimeType.startsWith('image/')) {
      extension = filePath.split('.').last;
      extension = (extension.length <= 4) ? extension : '';
    }
    extension = extension.isNotEmpty ? extension : 'img';
    var userEmail = user.email;
    userEmail = userEmail.replaceAll('@', '_at_');
    final uploadName = '$userEmail.$extension';
    return uploadName;
  }

  Future<UploadTask?> updateUserImage(my_app.User user) async {
    var ret = Future<UploadTask?>.value();
    if (user.imageBytes != null && user.imageBytes!.isNotEmpty) {
      final uploadName = await _getUserAvatarUploadName(user);
      final task = FilesDao().updateFileAsBytes(
          user.imageBytes!, FileType.USER_AVATAR, uploadName);
      ret = task;
    } else if (user.imageUrl != null &&
        user.imageUrl!.path.isNotEmpty &&
        !user.imageUrl!.isFromStorage()) {
      final uploadName = await _getUserAvatarUploadName(user);
      final task = FilesDao().uploadFileAsUri(
          user.imageUrl!, FileType.USER_AVATAR,
          uploadName: uploadName);
      ret = task;
    } else if (user.imageUrl != null && user.imageUrl!.path.isNotEmpty) {
      final uploadName = await _getUserAvatarUploadName(user);
      final task = FilesDao()
          .updateFileAsUri(user.imageUrl!, FileType.USER_AVATAR, uploadName);
      ret = task;
    } else {
      user.imageUrl = null;
    }
    return ret;
  }
}
