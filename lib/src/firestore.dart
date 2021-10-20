import 'package:cloud_firestore/cloud_firestore.dart' as p;
import 'package:zam_database/zam_database.dart';

import 'extensions/_.index.dart';

class Firestore extends Database {
  @override
  final DatabaseConfig config;

  final p.FirebaseFirestore db;

  Firestore({
    this.config = const DatabaseConfig(),
    String? host,
    bool? sslEnabled,
    bool persistenceEnabled = false,
  }) : db = p.FirebaseFirestore.instance;

  p.CollectionReference<ENTITY> getCollection<ENTITY extends Entity>(
    Table<ENTITY> table,
  ) {
    assert(table.path != null);

    return db.collection(table.path!).withConverter<ENTITY>(
          fromFirestore: (document, options) {
            if (!document.exists) {
              throw DocumentNotFoundInDatabaseException(
                table.path!,
                document.id,
              );
            }

            final data = document.data()!.map((key, value) => MapEntry(
                  key,
                  value.runtimeType == p.Timestamp ? value.toDate() : value,
                ));
            return table.createEntity({'key': document.id, ...data});
          },
          toFirestore: (document, options) => table.serialize(document),
        );
  }

  @override
  Future<bool> exists<ENTITY extends Entity>(
    Table<ENTITY> table, {
    required String key,
  }) async {
    if (table.path == null) {
      return false;
    }

    final documentSnapshot = await db.collection(table.path!).doc(key).get();
    return documentSnapshot.exists;
  }

  @override
  Future<ENTITY> get<ENTITY extends Entity>(
    Table<ENTITY> table, {
    required String key,
  }) {
    return getCollection(table).doc(key).getAndConvert();
  }

  @override
  Stream<ENTITY> stream<ENTITY extends Entity>(
    Table<ENTITY> table, {
    required String key,
  }) {
    return getCollection(table).doc(key).streamAndConvert();
  }

  @override
  Future<Iterable<ENTITY>> getAll<ENTITY extends Entity>(Table<ENTITY> table) {
    return getCollection(table).getAndConvert();
  }

  @override
  Stream<Iterable<ENTITY>> streamAll<ENTITY extends Entity>(
      Table<ENTITY> table) {
    return getCollection(table).streamAndConvert();
  }

  @override
  Future<Iterable<ENTITY>> getFirst<ENTITY extends Entity>(
    Table<ENTITY> table, {
    required int limit,
  }) {
    return getCollection(table).limit(limit).getAndConvert();
  }

  @override
  Future<Iterable<ENTITY>> getMultiple<ENTITY extends Entity>(
    Table<ENTITY> table, {
    required List<String> keys,
  }) {
    return getCollection(table)
        .where(p.FieldPath.documentId, whereIn: keys)
        .getAndConvert();
  }

  @override
  Stream<Iterable<ENTITY>> streamMultiple<ENTITY extends Entity>(
    Table<ENTITY> table, {
    required List<String> keys,
  }) {
    return getCollection(table)
        .where(p.FieldPath.documentId, whereIn: keys)
        .streamAndConvert();
  }
}
