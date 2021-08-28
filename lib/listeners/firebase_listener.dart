import 'dart:async';

// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:little_drops_of_rain_flutter/helpers/my_logger.dart';

abstract class EventListener<T> {
  void onEvent(T value, Exception? error);
}

abstract class NotifyDataSetChanged {
  void onDataSetChanged();
}

abstract class NotifyItemInserted {
  void onItemInserted(int newIndex);
}

abstract class NotifyItemChanged {
  void onItemChanged(int oldIndex);
}

abstract class NotifyItemMoved {
  void onItemMoved(int oldIndex, int newIndex);
}

abstract class NotifyItemRemoved {
  void onItemRemoved(int index);
}

class FirebaseListener implements EventListener<QuerySnapshot> {
  FirebaseListener(
      {Query<Map<String, dynamic>>? query,
      CollectionReference<Map<String, dynamic>>? collRef,
      Stream<QuerySnapshot<Map<String, dynamic>>>? stream}) {
    if (query != null) {
      setQuery(query);
    } else if (collRef != null) {
      setCollectionReference(collRef);
    } else if (stream != null) {
      setStreamOfQuerySnapshots(stream);
    }
  }

  NotifyItemRemoved? onItemRemoved;
  NotifyItemMoved? onItemMoved;
  NotifyItemChanged? onItemChanged;
  NotifyDataSetChanged? onDataSetChanged;
  NotifyItemInserted? onItemInserted;
  static Exception? exception;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? mRegistration;
  Stream<QuerySnapshot<Map<String, dynamic>>>? mQuerySnapshot;
  List<DocumentSnapshot<Map<String, dynamic>>> mSnapshots =
      <DocumentSnapshot<Map<String, dynamic>>>[];

  static void _completeError(Object error, StackTrace stackTrace) {
    exception = error as Exception;
  }

  void startListening() {
    MyLogger().logger.i('[startListening] Pre verification');
    if (mRegistration == null && mQuerySnapshot != null) {
      MyLogger().logger.i('[startListening] Verified');
      try {
        mRegistration = mQuerySnapshot!
            .listen((querySnapshot, {Function onError = _completeError}) {
          MyLogger().logger.i(
              '[startListening] onEvent triggered for ${querySnapshot.docChanges.length} doc changes. Exception:${(exception != null) ? exception.toString() : 'null'}');
          onEvent(querySnapshot, exception);
        });
        MyLogger().logger.i('[startListening] listening');
      } on Exception catch (ex) {
        MyLogger().logger.e(ex.toString());
      } on Error catch (ex) {
        MyLogger().logger.e(ex.toString());
      }
    }
  }

  void stopListening() {
    mRegistration?.cancel();
    mRegistration = null;
    mSnapshots.clear();
    onDataSetChanged?.onDataSetChanged();
  }

  @override
  void onEvent(QuerySnapshot value, Exception? e) {
    // Handle errors
    if (e != null) {
      MyLogger().logger.e('onEvent:error $e');
      exception = null;
      return;
    }

    // Dispatch the event
    for (final change in value.docChanges) {
      // Snapshot of the changed document
      switch (change.type) {
        case DocumentChangeType.added:
          _onDocumentAdded(change as DocumentChange<Map<String, dynamic>>);
          break;
        case DocumentChangeType.modified:
          _onDocumentModified(change as DocumentChange<Map<String, dynamic>>);
          break;
        case DocumentChangeType.removed:
          _onDocumentRemoved(change as DocumentChange<Map<String, dynamic>>);
          break;
      }
    }
    onDataChanged();
  }

  void _onDocumentAdded(DocumentChange<Map<String, dynamic>> change) {
    MyLogger()
        .logger
        .d('_onDocumentAdded:${change.doc.id} - new Index:${change.newIndex}');
    mSnapshots.insert(change.newIndex, change.doc);
    onItemInserted?.onItemInserted(change.newIndex);
  }

  void _onDocumentModified(DocumentChange<Map<String, dynamic>> change) {
    MyLogger().logger.d(
        '_onDocumentModified:${change.doc.id} - old Index:${change.oldIndex} - new Index:${change.newIndex}');
    if (change.oldIndex == change.newIndex) {
      // Item changed but remained in same position
      mSnapshots[change.oldIndex] = change.doc;
      onItemChanged?.onItemChanged(change.oldIndex);
    } else {
      // Item changed and changed position
      mSnapshots.removeAt(change.oldIndex);
      mSnapshots.insert(change.newIndex, change.doc);
      onItemMoved?.onItemMoved(change.oldIndex, change.newIndex);
    }
  }

  void _onDocumentRemoved(DocumentChange<Map<String, dynamic>> change) {
    MyLogger().logger.d(
        '_onDocumentRemoved:${change.doc.id} - old Index:${change.oldIndex}');
    mSnapshots.removeAt(change.oldIndex);
    onItemRemoved?.onItemRemoved(change.oldIndex);
  }

  void setStreamOfQuerySnapshots(
      Stream<QuerySnapshot<Map<String, dynamic>>> stream) {
    MyLogger().logger.i('Setting Stream<QuerySnapshot<Map<String, dynamic>>>');
    // Stop listening
    stopListening();

    // Listen to new query
    mQuerySnapshot = stream;
    startListening();
  }

  void setCollectionReference(
      CollectionReference<Map<String, dynamic>> collRef) {
    MyLogger().logger.i('Setting CollectionReference<Map<String, dynamic>>');
    // Stop listening
    stopListening();

    // Listen to new query
    mQuerySnapshot = collRef.snapshots();
    startListening();
  }

  void setQuery(Query<Map<String, dynamic>> query) {
    MyLogger().logger.i('Setting Query');
    // Stop listening
    stopListening();

    // Listen to new query
    mQuerySnapshot = query.snapshots();
    startListening();
  }

  int getItemCount() {
    return mSnapshots.length;
  }

  DocumentSnapshot getSnapshot(int index) {
    return mSnapshots[index];
  }

  List<DocumentSnapshot> getSnapshots() {
    return mSnapshots;
  }

  void onDataChanged() {
    MyLogger().logger.d('onDataChanged');
    onDataSetChanged?.onDataSetChanged();
  }

  void clearCache() {
    stopListening();
    startListening();
  }
}
