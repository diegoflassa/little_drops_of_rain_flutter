// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_storage/firebase_storage.dart';
import 'package:little_drops_of_rain_flutter/data/dao/files_dao.dart';
import 'package:little_drops_of_rain_flutter/data/entities/product.dart';
import 'package:little_drops_of_rain_flutter/enums/file_type.dart';
import 'package:little_drops_of_rain_flutter/extensions/uri_extensions.dart';
import 'package:little_drops_of_rain_flutter/helpers/helper.dart';
import 'package:little_drops_of_rain_flutter/helpers/images_cache.dart';
import 'package:little_drops_of_rain_flutter/helpers/my_logger.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:mime/mime.dart';
import 'package:pedantic/pedantic.dart';

class ProductsDao {
  factory ProductsDao() {
    return _instance;
  }

  ProductsDao._internal();

  static const String COLLECTION_PATH = 'products';
  CollectionReference<Map<String, dynamic>> products =
      FirebaseFirestore.instance.collection(COLLECTION_PATH);

  static final ProductsDao _instance = ProductsDao._internal();

  Future<List<String>> findReferences(String productUID) async {
    final ret = <String>[];
    final qse =
        await products.where(Product.ENEMIES_UIDS, arrayContains: productUID).get();
    final enemies = Helper.querySnapshotToProductsList(qse, nestedObjects: false);
    for (final enemy in enemies) {
      ret.add(enemy.codename);
    }
    final qsf =
        await products.where(Product.FRIENDS_UIDS, arrayContains: productUID).get();
    final friends = Helper.querySnapshotToProductsList(qsf, nestedObjects: false);
    for (final friend in friends) {
      ret.add(friend.codename);
    }
    return ret;
  }

  Future<List<Product>> getAll() async {
    final qs = await products.orderBy(Product.CREATION_DATE).get();
    return Helper.querySnapshotToProductsList(qs, nestedObjects: false);
  }

  Future<List<Product>> getAllUnpublished() async {
    final qs = await products
        .where(Product.PUBLISHED, isEqualTo: false)
        .orderBy(Product.CREATION_DATE)
        .get();
    return Helper.querySnapshotToProductsList(qs, nestedObjects: false);
  }

  Future<List<Product>> getAllPublished({bool nestedObjects = false}) async {
    final qs = await products
        .where(Product.PUBLISHED, isEqualTo: true)
        .orderBy(Product.CREATION_DATE)
        .get();
    return Helper.querySnapshotToProductsList(qs, nestedObjects: nestedObjects);
  }

  Future<List<Product>> getAllPublishedByCivilOrCodeName(String name,
      {String? universeUID, bool nestedObjects = false}) async {
    final ret = <Product>[];
    List<Product> allProducts;
    if (universeUID != null) {
      allProducts = await getAllPublishedByUniverse(universeUID);
    } else {
      final qs = await products.where(Product.PUBLISHED, isEqualTo: true).get();
      allProducts = Helper.querySnapshotToProductsList(qs);
    }
    for (final product in allProducts) {
      if (product.civilName.contains(name) ||
          product
              .getSanitizedCodename()
              .contains(Helper.stringToParameter(name)!)) {
        ret.add(product);
      }
    }
    return ret;
  }

  Future<List<Product>> getAllPublishedByCodeName(String name,
      {String? universeUID, bool nestedObjects = false}) async {
    final ret = <Product>[];
    List<Product> allProducts;
    if (universeUID != null) {
      allProducts = await getAllPublishedByUniverse(universeUID);
    } else {
      final qs = await products.where(Product.PUBLISHED, isEqualTo: true).get();
      allProducts = Helper.querySnapshotToProductsList(qs);
    }
    name = Helper.stringToParameter(name)!;
    for (final product in allProducts) {
      if (product.getSanitizedCodename().contains(name)) {
        ret.add(product);
      }
    }
    return ret;
  }

  Future<List<Product>> getAllUnpublishedPaginated(Product? startAt, int pageSize,
      {String orderBy = Product.CREATION_DATE, bool descending = false}) async {
    QuerySnapshot<Map<String, dynamic>> qs;
    if (startAt != null && startAt.reference != null) {
      qs = await products
          .where(Product.PUBLISHED, isEqualTo: false)
          .orderBy(orderBy, descending: descending)
          .startAfterDocument(await startAt.reference!.get())
          .limit(pageSize)
          .get();
    } else {
      qs = await products
          .where(Product.PUBLISHED, isEqualTo: false)
          .orderBy(orderBy, descending: descending)
          .limit(pageSize)
          .get();
    }
    return Helper.querySnapshotToProductsList(qs, nestedObjects: false);
  }

  Future<List<Product>> getAllPublishedPaginated(Product? startAt, int pageSize,
      {String orderBy = Product.CREATION_DATE, bool descending = false}) async {
    QuerySnapshot<Map<String, dynamic>> qs;
    if (startAt != null && startAt.reference != null) {
      qs = await products
          .where(Product.PUBLISHED, isEqualTo: true)
          .orderBy(orderBy, descending: descending)
          .startAfterDocument(await startAt.reference!.get())
          .limit(pageSize)
          .get();
    } else {
      qs = await products
          .where(Product.PUBLISHED, isEqualTo: true)
          .orderBy(orderBy, descending: descending)
          .limit(pageSize)
          .get();
    }
    return Helper.querySnapshotToProductsList(qs, nestedObjects: false);
  }

  Future<List<Product>> getAllByUserUID(String userUID,
      {String orderBy = Product.CREATION_DATE, bool descending = false}) async {
    QuerySnapshot<Map<String, dynamic>> qs;
    qs = await products
        .where(Product.USER_UID, isEqualTo: userUID)
        .orderBy(orderBy, descending: descending)
        .get();
    return Helper.querySnapshotToProductsList(qs, nestedObjects: false);
  }

  Future<List<Product>> getAllPaginatedByUserUID(
      String userUID, Product? startAt, int pageSize,
      {String orderBy = Product.CREATION_DATE, bool descending = false}) async {
    QuerySnapshot<Map<String, dynamic>> qs;
    if (startAt != null && startAt.reference != null) {
      qs = await products
          .where(Product.USER_UID, isEqualTo: userUID)
          .orderBy(orderBy, descending: descending)
          .startAfterDocument(await startAt.reference!.get())
          .limit(pageSize)
          .get();
    } else {
      qs = await products
          .where(Product.USER_UID, isEqualTo: userUID)
          .orderBy(orderBy, descending: descending)
          .limit(pageSize)
          .get();
    }
    return Helper.querySnapshotToProductsList(qs, nestedObjects: false);
  }

  Future<List<Product>> getAllByUniverse(String universeUID) async {
    final qs = await products
        .where(Product.UNIVERSE_UID, isEqualTo: universeUID)
        .orderBy(Product.CREATION_DATE)
        .get();
    return Helper.querySnapshotToProductsList(qs);
  }

  Future<List<Product>> getAllPublishedByUniverse(String universeUID) async {
    final qs = await products
        .where(Product.PUBLISHED, isEqualTo: true)
        .where(Product.UNIVERSE_UID, isEqualTo: universeUID)
        .orderBy(Product.CREATION_DATE)
        .get();
    return Helper.querySnapshotToProductsList(qs, nestedObjects: false);
  }

  Future<List<Product>> getAllUnpublishedByUniverse(String universeUID) async {
    final qs = await products
        .where(Product.PUBLISHED, isEqualTo: false)
        .where(Product.UNIVERSE_UID, isEqualTo: universeUID)
        .orderBy(Product.CREATION_DATE)
        .get();
    return Helper.querySnapshotToProductsList(qs, nestedObjects: false);
  }

  Future<Product?> getImages(String productUID) async {
    final qs = await products.where(Product.UID, isEqualTo: productUID).get();
    final allProducts = Helper.querySnapshotToProductsList(qs, getImages: true);
    if (allProducts.length == 1) {
      return allProducts.first;
    } else {
      return null;
    }
  }

  Future<Product?> getByUid(String productUID) async {
    final qs = await products.where(Product.UID, isEqualTo: productUID).get();
    final allProducts = Helper.querySnapshotToProductsList(qs);
    if (allProducts.length == 1) {
      return allProducts.first;
    } else {
      return null;
    }
  }

  Future<List<Product>> getAllByUid(List<String> productUIDs,
      {bool nestedObjects = false}) async {
    var allProductsByUID = <Product>[];
    if (productUIDs.isNotEmpty) {
      final qs = await products.where(Product.UID, whereIn: productUIDs).get();
      allProductsByUID =
          Helper.querySnapshotToProductsList(qs, nestedObjects: nestedObjects);
    }
    return allProductsByUID;
  }

  Future<List<Product>> getByUser(String userUID) async {
    final qs = await products.where(Product.USER_UID, isEqualTo: userUID).get();
    return Helper.querySnapshotToProductsList(qs, nestedObjects: false);
  }

  Future<Product?> getByUserAndProductUid(String userUID, String productUID) async {
    final qs = await products
        .where(Product.UID, isEqualTo: productUID)
        .where(Product.USER_UID, isEqualTo: userUID)
        .get();
    final allProducts = Helper.querySnapshotToProductsList(qs);
    if (allProducts.length == 1) {
      return allProducts.first;
    } else {
      return null;
    }
  }

  Future<List<Product>> getByCivilName(String name, {String? universeUID}) async {
    final ret = <Product>[];
    List<Product> allProducts;
    if (universeUID != null) {
      allProducts = await getAllByUniverse(universeUID);
    } else {
      final qs = await products.get();
      allProducts = Helper.querySnapshotToProductsList(qs);
    }
    for (final product in allProducts) {
      if ((product.civilName.contains(name)) &&
          (product.universeUID == universeUID)) {
        ret.add(product);
      }
    }
    return ret;
  }

  Future<List<Product>> getByCodeName(String name, {String? universeUID}) async {
    final ret = <Product>[];
    List<Product> allProducts;
    if (universeUID != null) {
      allProducts = await getAllByUniverse(universeUID);
    } else {
      final qs = await products.get();
      allProducts = Helper.querySnapshotToProductsList(qs);
    }
    name = Helper.stringToParameter(name)!;
    for (final product in allProducts) {
      if ((product.getSanitizedCodename().contains(name)) &&
          (product.universeUID == universeUID)) {
        ret.add(product);
      }
    }
    return ret;
  }

  Future<List<Product>> getByCivilOrCodeName(String name,
      {String? universeUID}) async {
    final ret = <Product>[];
    List<Product> allProducts;
    if (universeUID != null) {
      allProducts = await getAllByUniverse(universeUID);
    } else {
      final qs = await products.get();
      allProducts = Helper.querySnapshotToProductsList(qs);
    }
    for (final product in allProducts) {
      if (product.civilName.contains(name) ||
          product
              .getSanitizedCodename()
              .contains(Helper.stringToParameter(name)!)) {
        ret.add(product);
      }
    }
    return ret;
  }

  Future<void> update(Product product) async {
    if (product.uid != null) {
      if (product.imageUrl != null && !product.imageUrl!.isFromStorage()) {
        await updateProductImage(product).then((value) async {
          if (value != null) {
            await value.then((snapshot) async {
              if (snapshot.state == TaskState.success) {
                product.imageUrl = Uri.parse(await snapshot.ref.getDownloadURL());
                unawaited(ImagesCache.writeAsUri(
                    product.imageUrl!, (await snapshot.ref.getData())!));
                if (product.previousImageUrl != null &&
                    product.imageUrl!.lastPath() !=
                        product.previousImageUrl!.lastPath()) {
                  await FilesDao().deleteAsUri(product.previousImageUrl!);
                }
              } else {
                product.imageUrl = product.previousImageUrl;
              }
              if ((product.faceImageAsBytes != null &&
                      product.faceImageAsBytes!.isNotEmpty) ||
                  (product.faceImageUrl != null &&
                      !product.faceImageUrl!.isFromStorage())) {
                await updateProductFaceImage(product).then((value) {
                  if (value != null) {
                    value.then((snapshot) async {
                      if (snapshot.state == TaskState.success) {
                        product.faceImageUrl =
                            Uri.parse(await snapshot.ref.getDownloadURL());
                        unawaited(ImagesCache.writeAsUri(product.faceImageUrl!,
                            (await snapshot.ref.getData())!));
                        if (product.previousFaceImageUrl != null &&
                            product.faceImageUrl!.lastPath() !=
                                product.previousFaceImageUrl!.lastPath()) {
                          await FilesDao()
                              .deleteAsUri(product.previousFaceImageUrl!);
                        }
                      } else {
                        product.faceImageUrl = product.previousFaceImageUrl;
                      }
                      await _updateProduct(product);
                    });
                  }
                });
              } else {
                await _updateProduct(product);
              }
            });
          } else {
            await _updateProduct(product);
          }
        });
      } else {
        await _updateProduct(product);
      }
    } else {
      return Future.value(null);
    }
  }

  Future<void> _updateProductEnemiesAndFriends(Product product) async {
    final enemies = await getAllByUid(product.enemiesUIDS);
    final enemiesToRemove = <String>[];
    product.originalEnemiesUIDS.forEach((element) {
      if (!product.enemiesUIDS.contains(element)) {
        enemiesToRemove.add(element);
      }
    });
    final enemiesToRemoveList = await getAllByUid(enemiesToRemove);
    for (final enemy in enemies) {
      if (!enemy.enemiesUIDS.contains(product.uid)) {
        enemy.enemiesUIDS.add(product.uid!);
        await _updateProduct(enemy, updateFriendsAndEnemies: false);
      }
    }
    for (final enemy in enemiesToRemoveList) {
      if (enemy.enemiesUIDS.contains(product.uid)) {
        enemy.enemiesUIDS.remove(product.uid);
        await _updateProduct(enemy, updateFriendsAndEnemies: false);
      }
    }
    final friends = await getAllByUid(product.enemiesUIDS);
    final friendsToRemove = <String>[];
    product.originalFriendsUIDS.forEach((element) {
      if (!product.friendsUIDS.contains(element)) {
        friendsToRemove.add(element);
      }
    });
    for (final friend in friends) {
      if (!friend.friendsUIDS.contains(product.uid)) {
        friend.friendsUIDS.add(product.uid!);
        await _updateProduct(friend, updateFriendsAndEnemies: false);
      }
    }
    final friendsToRemoveList = await getAllByUid(friendsToRemove);
    for (final friend in friendsToRemoveList) {
      if (friend.enemiesUIDS.contains(product.uid)) {
        friend.enemiesUIDS.remove(product.uid);
        await _updateProduct(friend, updateFriendsAndEnemies: false);
      }
    }
  }

  Future<void> _updateProduct(Product product,
      {bool updateFriendsAndEnemies = true}) async {
    if (updateFriendsAndEnemies) {
      await _updateProductEnemiesAndFriends(product);
    }
    return products
        .doc(product.uid)
        .update(product.toMap())
        .then((value) => MyLogger().logger.i('Product Updated'))
        .catchError((dynamic error) =>
            MyLogger().logger.e('Failed to update product: $error'));
  }

  Future<void> delete(Product product) {
    if (product.uid != null) {
      return products.doc(product.uid).delete().then((value) {
        if (product.imageUrl != null) {
          FilesDao().deleteAsUri(product.imageUrl!);
        }
        if (product.faceImageUrl != null) {
          FilesDao().deleteAsUri(product.faceImageUrl!);
        }
        MyLogger().logger.i('Product Deleted');
      }).catchError((dynamic error) {
        MyLogger().logger.e('Failed to delete product: $error');
      });
    } else {
      return Future.value(null);
    }
  }

  Future<void> deleteAll() {
    final batch = FirebaseFirestore.instance.batch();
    return products.get().then((querySnapshot) {
      for (final document in querySnapshot.docs) {
        final documentMap = document.data();
        if (documentMap.containsKey(Product.IMAGE_URL)) {
          final imageUrl = documentMap[Product.IMAGE_URL] as String?;
          FilesDao().delete(imageUrl!);
        }
        if (documentMap.containsKey(Product.FACE_IMAGE_URL)) {
          final faceImageUrl = documentMap[Product.FACE_IMAGE_URL] as String?;
          FilesDao().delete(faceImageUrl!);
        }
        batch.delete(document.reference);
      }
      return batch.commit();
    });
  }

  Future<Product> add(Product product) async {
    if (product.uid == null) {
      if (product.imageUrl != null && product.imageUrl!.isFromStorage()) {
        await updateProductImage(product).then((value) async {
          if (value != null) {
            await value.then((snapshot) async {
              if (snapshot.state == TaskState.success) {
                product.imageUrl = Uri.parse(await snapshot.ref.getDownloadURL());
                unawaited(ImagesCache.writeAsUri(
                    product.imageUrl!, (await snapshot.ref.getData())!));
                if (product.previousImageUrl != null &&
                    product.imageUrl!.lastPath() !=
                        product.previousImageUrl!.lastPath()) {
                  await FilesDao().deleteAsUri(product.previousImageUrl!);
                }
              } else {
                product.imageUrl = product.previousImageUrl;
              }
              await _updateProductFaceImageAndId(product);
            });
          } else {
            await _updateProductFaceImageAndId(product);
          }
        });
      } else {
        await _updateProductFaceImageAndId(product);
      }
    } else {
      await update(product);
    }
    return Future.value(product);
  }

  Future<void> _updateProductFaceImageAndId(Product product) async {
    return updateProductFaceImage(product).then((value) async {
      if (value != null) {
        await value.then((snapshot) async {
          if (snapshot.state == TaskState.success) {
            product.faceImageUrl = Uri.parse(await snapshot.ref.getDownloadURL());
            unawaited(ImagesCache.writeAsUri(
                product.faceImageUrl!, (await snapshot.ref.getData())!));
            if (product.previousFaceImageUrl != null &&
                product.faceImageUrl!.lastPath() !=
                    product.previousFaceImageUrl!.lastPath()) {
              await FilesDao().deleteAsUri(product.previousFaceImageUrl!);
            }
          } else {
            product.faceImageUrl = product.previousFaceImageUrl;
          }
          await _addAndUpdateProductId(product);
        });
      } else {
        await _addAndUpdateProductId(product);
      }
    });
  }

  Future<void> _addAndUpdateProductId(Product product) async {
    final dr = await products.add(product.toMap());
    product.uid = dr.id;
    unawaited(update(product));
  }

  Future<String> _getUploadImageName(Product product) async {
    var renamedFile = '';
    String? mimeType;
    if (product.imageUrl != null) {
      renamedFile = product.imageUrl.toString();
      final bytes = await product.imageUrl!.downloadBytes();
      mimeType = lookupMimeType(renamedFile, headerBytes: bytes);
    }
    var extension = '';
    if (mimeType != null && mimeType.startsWith('image/')) {
      extension = renamedFile.split('.').last;
      extension = (extension.length <= 4) ? extension : '';
    }
    extension = extension.isNotEmpty ? extension : 'img';
    var universeName = 'no_universe';
    final uploadName =
        '${Helper.stringToParameter(universeName)}_${product.getSanitizedCodename()}.$extension';
    return uploadName;
  }

  Future<String> _getUploadFaceImageName(Product product) async {
    var renamedFile = '';
    String? mimeType;
    if (product.faceImageUrl != null) {
      renamedFile = product.faceImageUrl.toString();
      final bytes = await product.imageUrl!.downloadBytes();
      mimeType = lookupMimeType(renamedFile, headerBytes: bytes);
    }
    var extension = '';
    if (mimeType != null && mimeType.startsWith('image/')) {
      extension = renamedFile.split('.').last;
      extension = (extension.length <= 4) ? extension : '';
    }
    extension = extension.isNotEmpty ? extension : 'img';
    final universeName = 'no_universe';
    final uploadName =
        '${Helper.stringToParameter(universeName)}_${product.getSanitizedCodename()}_face.$extension';
    return uploadName;
  }

  Future<UploadTask?> updateProductImage(Product product) async {
    Future<UploadTask?>? ret;
    if (product.imageUrl != null &&
        product.imageUrl!.path.isNotEmpty &&
        !product.imageUrl!.isFromStorage()) {
      final uploadName = await _getUploadImageName(product);
      final task =
          FilesDao().updateFileAsUri(product.imageUrl!, FileType.HERO, uploadName);
      ret = task;
    } else if (product.imageUrl != null && product.imageUrl!.path.isNotEmpty) {
      final uploadName = await _getUploadImageName(product);
      if (!product.imageUrl!.path.endsWith(uploadName)) {
        final task = FilesDao()
            .updateFileAsUri(product.imageUrl!, FileType.HERO, uploadName);
        ret = task;
      }
    } else {
      product.imageUrl = null;
    }
    return ret;
  }

  Future<UploadTask?> updateProductFaceImage(Product product) async {
    Future<UploadTask?>? ret;
    if (product.faceImageAsBytes != null && product.faceImageAsBytes!.isNotEmpty) {
      final uploadName = await _getUploadFaceImageName(product);
      final task = FilesDao()
          .updateFileAsBytes(product.faceImageAsBytes!, FileType.HERO, uploadName);
      ret = task;
    } else if (product.faceImageUrl != null &&
        product.faceImageUrl!.path.isNotEmpty &&
        !product.faceImageUrl!.isFromStorage()) {
      final uploadName = await _getUploadFaceImageName(product);
      final taskFace = FilesDao()
          .updateFileAsUri(product.faceImageUrl!, FileType.HERO_FACE, uploadName);
      ret = taskFace;
    } else if (product.faceImageUrl != null &&
        product.faceImageUrl!.path.isNotEmpty) {
      final uploadName = await _getUploadFaceImageName(product);
      if (!product.faceImageUrl!.path.endsWith(uploadName)) {
        final task = FilesDao()
            .updateFileAsUri(product.faceImageUrl!, FileType.HERO, uploadName);
        ret = task;
      }
    } else {
      product.faceImageUrl = null;
    }
    return ret;
  }
}
