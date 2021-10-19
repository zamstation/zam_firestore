import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zam_database/zam_database.dart';

extension DocumentReferenceExtension on DocumentReference<Entity> {
  Future<ENTITY> getAndConvert<ENTITY extends Entity>() {
    return (this as DocumentReference<ENTITY>).get().then((doc) => doc.data()!);
  }

  Stream<ENTITY> streamAndConvert<ENTITY extends Entity>() {
    return (this as DocumentReference<ENTITY>)
        .snapshots()
        .map((doc) => doc.data()!);
  }
}