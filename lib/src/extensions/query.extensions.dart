import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zam_database/zam_database.dart';

extension QueryExtension on Query<Entity> {
  Future<Iterable<ENTITY>> getAndConvert<ENTITY extends Entity>() {
    return (this as Query<ENTITY>)
        .get()
        .then((query) => query.docs.map((doc) => doc.data()));
  }

  Stream<Iterable<ENTITY>> streamAndConvert<ENTITY extends Entity>() {
    return (this as Query<ENTITY>)
        .snapshots()
        .map((query) => query.docs.map((doc) => doc.data()));
  }
}
