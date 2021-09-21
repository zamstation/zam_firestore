import 'package:cloud_firestore/cloud_firestore.dart' as p;
import 'package:zam_database/zam_database.dart';

export 'package:zam_database/zam_database.dart' show DatabaseConfig;

class Firestore extends Database {
  @override
  final DatabaseConfig config;

  final p.FirebaseFirestore db;

  Firestore({
    this.config = const DatabaseConfig(),
    String? host,
    bool? sslEnabled,
    bool persistenceEnabled = false,
  }) : db = p.FirebaseFirestore.instance
          ..settings = p.Settings(
            host: host,
            sslEnabled: sslEnabled,
            persistenceEnabled: persistenceEnabled,
          );

  p.CollectionReference<ENTITY> getCollection<ENTITY extends Entity>(
    Table<ENTITY> table,
  ) {
    assert(table.path != null);

    return db.collection(table.path!).withConverter<ENTITY>(
          fromFirestore: (document, options) {
            if (!document.exists)
              throw 'DocumentNotFoundError: Document with id \'${document.id}\' not found.';
            return table
                .createEntity({'key': document.id, ...document.data()!});
          },
          toFirestore: (document, options) => table.serialize(document),
        );
  }

  @override
  Future<bool> exists<ENTITY extends Entity>(
    Table<ENTITY> table, {
    required String key,
  }) {
    return getCollection(table).doc(key).get().then((value) => value.exists);
  }

  @override
  Future<ENTITY> get<ENTITY extends Entity>(
    Table<ENTITY> table, {
    required String key,
  }) {
    return getCollection(table).doc(key).getAndConvert();
  }

  @override
  Future<Iterable<ENTITY>> getAll<ENTITY extends Entity>(Table<ENTITY> table) {
    return getCollection(table).getAndConvert();
  }

  @override
  Future<Iterable<ENTITY>> getFirst<ENTITY extends Entity>(
    Table<ENTITY> table, {
    required int limit,
  }) {
    return getCollection(table).limit(limit).getAndConvert();
  }

  @override
  Stream<ENTITY> stream<ENTITY extends Entity>(
    Table<ENTITY> table, {
    required String key,
  }) {
    return getCollection(table).doc(key).streamAndConvert();
  }

  @override
  Stream<Iterable<ENTITY>> streamAll<ENTITY extends Entity>(
      Table<ENTITY> table) {
    return getCollection(table).streamAndConvert();
  }
}

extension on p.Query<Entity> {
  Future<Iterable<ENTITY>> getAndConvert<ENTITY extends Entity>() {
    return (this as p.Query<ENTITY>)
        .get()
        .then((query) => query.docs.map((doc) => doc.data()));
  }

  Stream<Iterable<ENTITY>> streamAndConvert<ENTITY extends Entity>() {
    return (this as p.Query<ENTITY>)
        .snapshots()
        .map((query) => query.docs.map((doc) => doc.data()));
  }
}

extension on p.DocumentReference<Entity> {
  Future<ENTITY> getAndConvert<ENTITY extends Entity>() {
    return (this as p.DocumentReference<ENTITY>)
        .get()
        .then((doc) => doc.data()!);
  }

  Stream<ENTITY> streamAndConvert<ENTITY extends Entity>() {
    return (this as p.DocumentReference<ENTITY>)
        .snapshots()
        .map((doc) => doc.data()!);
  }
}
